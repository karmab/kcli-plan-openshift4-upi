{%- for operator in olm_operators -%}
oc create -f /root/operators/{{ operator }}.yml
{% endfor -%}
