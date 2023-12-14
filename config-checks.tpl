{{- /* Template based on https://github.com/codeclimate/platform/blob/master/spec/analyzers/SPEC.md#data-types */ -}}
[
  {{- $t_first := true }}
  {{- range . }}
  {{- $target := .Target }}
    {{- if ne .Target "OS Packages" -}}
      {{- range .Misconfigurations -}}
      {{- if $t_first -}}
        {{- $t_first = false -}}
      {{ else -}}
        ,
      {{- end }}
      {
        "type": "issue",
        "check_name": "config_scanning",
        "categories": [ "Security" ],
        "description": {{ list .Title .Description .Message .Resolution | compact | join "\n"  | quote }},
        "fingerprint": "{{ list .ID .Message $target | compact | join "" | sha1sum }}",
        "content": {{ .Type | printf "%q" }},
        "severity": {{ if eq .Severity "LOW" -}}
                      "info"
                    {{- else if eq .Severity "MEDIUM" -}}
                      "minor"
                    {{- else if eq .Severity "HIGH" -}}
                      "major"
                    {{- else if eq .Severity "CRITICAL" -}}
                      "critical"
                    {{-  else -}}
                      "info"
                    {{- end }},
        "location": {
          "path": {{ $target | quote }}
        }
      }
      {{- end -}}
    {{- end}}
  {{- end }}
]
