from canonicalwebteam.flask_base.app import FlaskBase
from canonicalwebteam.templatefinder import TemplateFinder
from canonicalwebteam import image_template

from flask import render_template


app = FlaskBase(
    __name__,
    "canonical.desgin",
    template_folder="../templates",
    static_folder="../static",
)


@app.context_processor
def utility_processor():
    return {"image": image_template}

@app.errorhandler(Exception)
def render_error_page(error):
    error_code = getattr(error, "code", 500)
    error_message = getattr(error, "description", "Something went wrong!")
    return render_template(
        "error.html", error_code=int(error_code), error_message=error_message
    )

template_finder_view = TemplateFinder.as_view("template_finder")
app.add_url_rule("/", view_func=template_finder_view)
app.add_url_rule("/<path:subpath>", view_func=template_finder_view)
