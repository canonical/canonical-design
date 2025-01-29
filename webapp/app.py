import requests

from flask import render_template, request
from urllib.parse import parse_qs, urlencode

from canonicalwebteam.flask_base.app import FlaskBase
from canonicalwebteam.blog import build_blueprint, BlogViews, BlogAPI
from canonicalwebteam.templatefinder import TemplateFinder
from canonicalwebteam import image_template

app = FlaskBase(
    __name__,
    "canonical.desgin",
    template_folder="../templates",
    static_folder="../static",
)

session = requests.Session()


@app.errorhandler(Exception)
def render_error_page(error):
    error_code = getattr(error, "code", 500)
    error_message = getattr(error, "description", "Something went wrong!")
    return render_template(
        "error.html", error_code=int(error_code), error_message=error_message
    )


blog_views = BlogViews(
    api=BlogAPI(
        session=session,
        api_url="https://ubuntu.com/blog/wp-json/wp/v2",
        thumbnail_width=354,
        thumbnail_height=180,
    ),
    blog_title="Design blog",
    tag_ids=[1239],
    excluded_tags=[3184, 3599, 3265, 4491],
    per_page=11,
)

app.register_blueprint(build_blueprint(blog_views), url_prefix="/blog")
template_finder_view = TemplateFinder.as_view("template_finder")
app.add_url_rule("/", view_func=template_finder_view)
app.add_url_rule("/<path:subpath>", view_func=template_finder_view)


def modify_query(params):
    query_params = parse_qs(
        request.query_string.decode("utf-8"), keep_blank_values=True
    )
    query_params.update(params)

    return urlencode(query_params, doseq=True)


@app.context_processor
def utility_processor():
    return {
        "modify_query": modify_query,
        "image": image_template,
    }
