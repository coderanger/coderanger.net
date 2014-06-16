---
title: LazyProfile Middleware
---

The topic of extending the User model in Django came up recently on
~~[Convore](https://convore.com/django-community/customizing-your-user-model/)~~.
In the discussion I mentioned a minor hack we had come up with at work to
reduce the friction of working with user profile models (which are still the
safest way to add extra fields to User).

The LazyProfileMiddleware adds a ``request.profile`` in the same style as
AuthenticationMiddleware adds a ``request.user``. The only point of warning is
that also like AuthenticationMiddleware, this cannot be enabled for only one
site in a multi-tenant deployment scenario.

```python
class LazyProfileMiddleware(object):
    """Middleware to attach a lazy .profile value to all requests."""

    lazy_profile = property(lambda self: self.user.get_profile() if self.user else None)

    def process_request(self, request):
        request.__class__.profile = self.lazy_profile
```
