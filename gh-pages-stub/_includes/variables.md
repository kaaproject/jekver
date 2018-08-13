{% assign url_array = page.url | split: '/' %}
{% capture version %}{{url_array[2]}}{% endcapture %}
{% assign latest_version = site.data.generated_config.version%}
{% assign root_url = page.url | split: '/'%}
{% capture root_url %}{{ site.baseurl }}/{{root_url[1]}}/{{root_url[2]}}/{% endcapture %}
{% assign base_docs_path = site.data.generated_config.docs_root %}
{% capture path %}/{{base_docs_path}}/{{site.data.generated_config.version}}/{% endcapture %}
{% capture home_url %}{{ site.baseurl }}/{{ site.data.generated_config.docs_root }}/{{ latest_version }}{% endcapture %}
{% capture versions%}{% endcapture %}
{% for hash in site.data.versions %}
	{% capture versions %}{{ versions }} {{ hash[1].version }} {% endcapture %}
{% endfor %}
{% assign versions = versions | split: ' ' %}
{% if versions contains version %}
{% else %}
	{% assign version = "" %}
{% endif %}
{% assign github_url = "" %}
{% if version == "current" %}
	{% assign github_url = site.data.permanent_config.github_url_latest %}
{% else %}
	{% capture github_url %}{{site.data.permanent_config.github_url}}tree/{{version}}/{% endcapture %}
{% endif %}
{% assign github_url_raw = "" %}
{% if version == "current" %}
    {% assign github_url_raw = site.data.permanent_config.github_url_raw_latest %}
{% else %}
    {% capture github_url_raw %}{{site.data.permanent_config.github_url_raw}}{{version}}/{% endcapture %}
{% endif %}
{% assign component_mapping = site.data.component_mapping[version] %}
{% assign sandbox_frame_url = component_mapping["Sandbox frame"] %}
{% assign sample_apps_url   = component_mapping["Sample Apps"] %}
{% assign rfc_url           = "https://github.com/kaaproject/kaa-rfcs/blob/master/" %}
{% assign docs_url          = "https://docs.kaaiot.io/" %}
{% assign kaa_org           = "https://www.kaaproject.org/" %}
{% assign _1kp	  			= rfc_url | append: "0001/README.md" %}
{% assign _2dcp	  			= rfc_url | append: "0002/README.md" %}
{% assign _3ism	  			= rfc_url | append: "0003/README.md" %}
{% assign _4esp	  			= rfc_url | append: "0004/README.md" %}
{% assign _6cdtp  			= rfc_url | append: "0006/README.md" %}
{% assign _7cmp	  			= rfc_url | append: "0007/README.md" %}
{% assign _8kpsr  			= rfc_url | append: "0008/README.md" %}
{% assign _9elce  			= rfc_url | append: "0009/README.md" %}
{% assign _10epmp  			= rfc_url | append: "0010/README.md" %}
{% assign _11cep  			= rfc_url | append: "0011/README.md" %}
{% assign _12cip  			= rfc_url | append: "0012/README.md" %}
{% assign _13dstp  			= rfc_url | append: "0013/README.md" %}
{% assign _14tstp  			= rfc_url | append: "0014/README.md" %}
{% assign _15eme  			= rfc_url | append: "0015/README.md" %}
{% assign _16ecap  			= rfc_url | append: "0016/README.md" %}
{% assign _17scp  			= rfc_url | append: "0017/README.md" %}
{% assign _18efe  			= rfc_url | append: "0018/README.md" %}