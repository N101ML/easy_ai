import functools

from flask import (
  Blueprint, flash, g, redirect, render_template, request, session, url_for
)

bp = Blueprint('replicate', __name__, url_prefix='/replicate')