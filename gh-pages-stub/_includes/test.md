{% include variables.md %}
{% if version != latest_version %}

  {% assign urls = site.pages | map: 'url' %}
  {% assign new_url = page.url | replace_first: version, latest_version %}
  {% if urls contains new_url %}

  > You are looking at the outdated documentation version. New version is available [here]({{ site.baseurl }}{{new_url}}).

  {% else %}

  > You are looking at the outdated documentation version. New version is available [here]({{home_url}}).

  {% endif %}
{% endif %}
