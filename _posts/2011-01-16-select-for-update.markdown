---
layout: post
title: "Using SELECT FOR UPDATE in Django"
---
A frequently overlooked feature of SQL is the `FOR UPDATE` clause on `SELECT`.
Even in this age of NoSQL datastores, most large-scale webapps will use a
relational database somewhere, and good money would bet on most having a
transaction race condition somewhere.

Transaction isolation in a nutshell
-----------------------------------

Transaction isolation is the mechanism by which a SQL database prevents
multiple in-progress transactions from interfering with each other. Postgres
provides two different levels, *read committed* and *serializable*. *Read
committed* is the default and is sufficient for the vast majority of
operations. A simple mental model for how this works is to have a dirty
flag on each row. Any time a row is touched by an `UPDATE` or `DELETE` statement,
the dirty is set. Similarly any time a `SELECT` is about to operate on a dirty
row, more specifically one which was marked dirty by another transaction, it
will block and wait for the other transaction to either commit or rollback and
will then update the value it was trying to access.

Using UPDATE
------------

As long as you can express all your operations using SQL expressions in an
`UPDATE`, this isolation is sufficient. For example, you can increment an
integer column via `UPDATE foo SET x=x+1 WHERE id=1;`. Unfortunately Django
doesn't make this easy. The naive way to perform the same operation is:
{% highlight python %}
obj = Foo.objects.get(id=1)
obj.x += 1
obj.save()
{% endhighlight %}

This means that two requests can come in simultaneously and the second
will clobber the first:
{% highlight python %}
A: obj = Foo.objects.get(id=1) # obj.x is now 1
B: obj = Foo.objects.get(id=1)
A: obj.x += 1 # obj.x is now 2
B: obj.x += 1 
A: obj.save() # obj.x saved as 2, as expected
B: obj.save() # obj.x is still only 2, when it should be 3
{% endhighlight %}

To do this correctly in plain Django calls, we can use
[QuerySet.update](http://docs.djangoproject.com/en/1.2/ref/models/querysets/#update)
and an [F expression](http://docs.djangoproject.com/en/1.2/topics/db/queries/#filters-can-reference-fields-on-the-model):
{% highlight python %}
Foo.objects.filter(id=1).update(x=F('x')+1)
{% endhighlight %}

This works, but the syntax is a bit unfortunate, even moreso when you just
want to update a field on a model you already have. I highly recommend using
Andy McCurdy's [update method](https://github.com/andymccurdy/django-tips-and-tricks/blob/master/model_update.py):
{% highlight python %}
obj = Foo.objects.get(id=1)
update(obj, x=F('x')+1)
{% endhighlight %}

Using `update()` like this also has the added advantage of only sending the
given fields to the database, as opposed to `save()` which serializes the
entire model (possibly causing race conditions even on fields you didn't
modify).

The need for FOR UPDATE
-----------------------

Where things start to break down is when you need to update a row using more
complex code. One option is to use stored procedures, but this is effectively
impossible to do while keeping mutli-database compatibility. The other option
is to do the computation in Python code. Without `FOR UPDATE` this puts us
back into race-condition territory in the same way as `Model.save()`. What
`FOR UPDATE` does is to set the same dirty flags that `UPDATE` and `DELETE`
use before returning the rows. This means that no other transaction can
alter it.

Unfortunately the Django ORM doesn't [yet](http://code.djangoproject.com/ticket/2705) expose `FOR UPDATE` as part of
the query system, but with some creativity we can add it in. Much of the
credit for this goes to [Alexander Artemenko](http://dev.svetlyak.ru/select-update-django-en/)
who wrote the initial version of the helper.

{% highlight python %}
from django.db import models, connections
from django.db.models.query import QuerySet

class ForUpdateQuerySet(QuerySet):
    def for_update(self):
        if 'sqlite' in connections[self.db].settings_dict['ENGINE'].lower():
            # Noop on SQLite since it doesn't support FOR UPDATE
            return self
        sql, params = self.query.get_compiler(self.db).as_sql()
        return self.model._default_manager.raw(sql.rstrip() + ' FOR UPDATE', params)

class ForUpdateManager(models.Manager):
    def get_query_set(self):
        return ForUpdateQuerySet(self.model, using=self._db)
{% endhighlight %}

Then all you have to do is inherit from `ForUpdateManager` in your manager and
use `for_update()` at the end of the filter chain:

{% highlight python %}
qs = Foo.objects.filter(id=1).for_update()
obj = qs[0]
update(obj, x=something_complex())
{% endhighlight %}

An example
----------

Our main use case at Atari for all of this is updating a user's billing information,
specifically their next billing date for people on monthly cycles. Due to the
nature of MMOs, it is possible that someone could redeem a game-time card at
the exact moment that a background task is processing them for monthly billing.
At heart this code boils down to:
{% highlight python %}
user = User.objects.filter(id=1).for_update()[0]
new_date = user.next_billing_date + relativedelta(months=1, day=user.next_billing_day)
update(user, next_billing_date=new_date)
{% endhighlight %}

This is both transactionally safe and concise, which is just about all you
can ask for from a SQL database.
