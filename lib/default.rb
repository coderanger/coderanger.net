# The require inside Nanoc::Filter::Erubis seems to have issues inside guard
require 'erubis'

include Nanoc::Helpers::Blogging
include Nanoc::Helpers::XMLSitemap
