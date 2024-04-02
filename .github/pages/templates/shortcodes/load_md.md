{% set data = load_data(path=id) %}
{{ data | safe }}
