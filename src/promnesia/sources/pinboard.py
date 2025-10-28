'''
Uses [[https://github.com/karlicoss/HPI][HPI]] for Pinboard bookmarks
'''

from promnesia.common import Loc, Results, Visit


def index() -> Results:
    from urllib.parse import quote

    from my.pinboard import bookmarks

    from . import hpi  # noqa: F401

    for bm in bookmarks():
        # Build rich context: tags + description/notes
        # Using HTML format with !html prefix to enable clickable tags in hover popup
        context_parts = []

        if bm.tags:
            # Generate clickable tag links for Pinboard tag searches
            tag_links = []
            for tag in bm.tags:
                tag_url = f"https://pinboard.in/u:saeculara/t:{quote(tag)}/"
                tag_links.append(f'<a href="{tag_url}">{tag}</a>')

            tags_html = ', '.join(tag_links)
            context_parts.append(f"Tags: {tags_html}")

        if bm.description:
            # Remove HTML tags from description for cleaner context
            import re
            clean_desc = re.sub(r'<[^>]+>', '', bm.description)
            clean_desc = clean_desc.strip()
            if clean_desc:
                # Escape HTML in description to prevent injection
                import html
                clean_desc = html.escape(clean_desc)
                context_parts.append(clean_desc)

        # Prefix with !html to signal HTML rendering in hover popup
        if context_parts:
            context = '!html ' + '<br>'.join(context_parts)
        else:
            context = None

        # Create Pinboard search URL for this bookmark
        # API v1 doesn't provide bookmark IDs, so we search by title instead
        # Pinboard search doesn't handle URLs well (special character parsing errors)
        # Title search is more reliable and takes user to the bookmark
        # Wrap title in quotes for exact match searching
        bookmark_title = bm.title or 'pinboard'
        quoted_title = f'"{bookmark_title}"'
        bookmark_url = f"https://pinboard.in/search/u:saeculara?query={quote(quoted_title)}"

        yield Visit(
            url=bm.url,
            dt=bm.created,
            context=context,
            locator=Loc.make(
                title=bm.title or 'pinboard',
                href=bookmark_url
            ),
        )
