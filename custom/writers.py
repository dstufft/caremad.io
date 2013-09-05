import os.path

from liquidluck.options import g, settings
from liquidluck.writers import core
from liquidluck.writers.base import get_post_slug


def get_post_destination(post, slug_format):
    slug = get_post_slug(post, slug_format)

    if slug.endswith('.html'):
        return slug
    elif slug.endswith("/"):
        return slug + 'index.html'
    else:
        return slug + '.html'


class PostWriter(core.PostWriter):

    def _dest_of(self, post):
        dest = get_post_destination(post, settings.config['permalink'])
        return os.path.join(g.output_directory, dest)


class PageWriter(core.PageWriter):

    def start(self):
        l = len(g.source_directory) + 1
        for post in g.pure_pages:
            template = post.template or self._template
            filename = os.path.splitext(post.filepath[l:])[0] + '/index.html'
            dest = os.path.join(g.output_directory, filename)
            self.render({'post': post}, template, dest)
