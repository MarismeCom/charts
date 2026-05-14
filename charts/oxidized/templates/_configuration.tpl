{{- define "oxidized.defaultConfiguration" -}}
username: {{ .Values.config.core.usernamePlaceholder | quote }}
password: {{ .Values.config.core.passwordPlaceholder | quote }}
model: {{ .Values.config.core.model | quote }}
resolve_dns: {{ .Values.config.core.resolveDns }}
interval: {{ .Values.config.core.interval }}
use_syslog: {{ .Values.config.core.useSyslog }}
{{ if .Values.config.core.log }}
log: {{ .Values.config.core.log | quote }}
{{ end }}
debug: {{ .Values.config.core.debug }}
run_once: {{ .Values.config.core.runOnce }}
threads: {{ .Values.config.core.threads }}
use_max_threads: {{ .Values.config.core.useMaxThreads }}
timeout: {{ .Values.config.core.timeout }}
timelimit: {{ .Values.config.core.timelimit }}
retries: {{ .Values.config.core.retries }}
prompt: !ruby/regexp {{ .Values.config.core.prompt }}
next_adds_job: {{ .Values.config.core.nextAddsJob }}
vars:
  {{ if .Values.config.vars.enable.enabled }}
  enable: {{ .Values.config.vars.enable.value | quote }}
  {{ end }}
  remove_secret: {{ .Values.config.vars.removeSecret }}
  {{ if .Values.config.vars.metadata.enabled }}
  metadata: {{ .Values.config.vars.metadata.value }}
  {{ if .Values.config.vars.metadata.top }}
  metadata_top: {{ .Values.config.vars.metadata.top | quote }}
  {{ end }}
  {{ if .Values.config.vars.metadata.bottom }}
  metadata_bottom: {{ .Values.config.vars.metadata.bottom | quote }}
  {{ end }}
  {{ end }}
  {{ if .Values.config.vars.outputStoreMode.enabled }}
  output_store_mode: {{ .Values.config.vars.outputStoreMode.value | quote }}
  {{ end }}
  {{ range $key, $value := .Values.config.vars.extra }}
  {{ $key | snakecase }}: {{ $value | quote }}
  {{ end }}
{{ if empty .Values.config.groupMap }}
group_map: {}
{{ else }}
group_map:
  {{ toYaml .Values.config.groupMap | nindent 2 }}
{{ end }}
pid: {{ .Values.config.core.pid | quote }}
{{ if .Values.config.rest.enabled }}
rest: {{ printf "%s:%v" .Values.config.rest.listen .Values.config.rest.port | quote }}
{{ if .Values.config.rest.urlPrefix }}
rest_prefix: {{ .Values.config.rest.urlPrefix | quote }}
{{ end }}
{{ end }}
{{ if .Values.config.logger.enabled }}
logger:
  level: {{ .Values.config.logger.level }}
  {{ if .Values.config.logger.appenders }}
  appenders:
    {{ toYaml .Values.config.logger.appenders | nindent 4 }}
  {{ end }}
{{ end }}
{{ if .Values.config.extensions.oxidizedWeb.enabled }}
extensions:
  oxidized-web:
    load: {{ .Values.config.extensions.oxidizedWeb.load }}
    listen: {{ .Values.config.extensions.oxidizedWeb.listen | quote }}
    port: {{ .Values.config.extensions.oxidizedWeb.port }}
    {{ if .Values.config.extensions.oxidizedWeb.urlPrefix }}
    url_prefix: {{ .Values.config.extensions.oxidizedWeb.urlPrefix | quote }}
    {{ end }}
    {{ if .Values.config.extensions.oxidizedWeb.vhosts }}
    vhosts:
      {{ range .Values.config.extensions.oxidizedWeb.vhosts }}
      - {{ . | quote }}
      {{ end }}
    {{ end }}
{{ end }}
crash:
  directory: {{ .Values.config.crash.directory | quote }}
  hostnames: {{ .Values.config.crash.hostnames }}
stats:
  history_size: {{ .Values.config.stats.historySize }}
input:
  default: {{ .Values.config.input.default | quote }}
  debug: {{ .Values.config.input.debug }}
  {{ if .Values.config.input.ssh.enabled }}
  ssh:
    secure: {{ .Values.config.input.ssh.secure }}
    auth_methods:
      {{ range .Values.config.input.ssh.authMethods }}
      - {{ . | quote }}
      {{ end }}
    {{ if .Values.config.input.ssh.sshKeys }}
    keys:
      {{ range .Values.config.input.ssh.sshKeys }}
      - {{ . | quote }}
      {{ end }}
    {{ end }}
    ssh_no_exec: {{ .Values.config.input.ssh.sshNoExec }}
    ssh_no_keepalive: {{ .Values.config.input.ssh.sshNoKeepalive }}
    kex: {{ join "," .Values.config.input.ssh.kex }}
    encryption: {{ join "," .Values.config.input.ssh.encryption }}
    hmac: {{ join "," .Values.config.input.ssh.hmac }}
  {{ end }}
  {{ if .Values.config.input.telnet.enabled }}
  telnet:
    secure: {{ .Values.config.input.telnet.secure }}
  {{ end }}
  utf8_encoded: {{ .Values.config.input.utf8Encoded }}
output:
  default: {{ .Values.config.output.default | quote }}
  clean_obsolete_nodes: {{ .Values.config.output.cleanObsoleteNodes }}
  {{ if .Values.config.output.git.enabled }}
  git:
    user: {{ .Values.config.output.git.user | quote }}
    email: {{ .Values.config.output.git.email | quote }}
    repo: {{ .Values.config.output.git.repo | quote }}
    single_repo: {{ .Values.config.output.git.singleRepo }}
  {{ end }}
  {{ if .Values.config.output.file.enabled }}
  file:
    directory: {{ .Values.config.output.file.directory | quote }}
  {{ end }}
  {{ if .Values.config.output.http.enabled }}
  http:
    url: {{ .Values.config.output.http.url | quote }}
    {{ if .Values.config.output.http.user }}
    user: {{ .Values.config.output.http.user | quote }}
    {{ end }}
    {{ if .Values.config.output.http.password }}
    password: {{ .Values.config.output.http.password | quote }}
    {{ end }}
    ssl_verify: {{ .Values.config.output.http.sslVerify }}
    {{ if .Values.config.output.http.headers }}
    headers:
      {{ range $key, $value := .Values.config.output.http.headers }}
      {{ $key }}: {{ $value | quote }}
      {{ end }}
    {{ end }}
  {{ end }}
  {{ if .Values.config.output.gitCrypt.enabled }}
  gitcrypt:
    user: {{ .Values.config.output.gitCrypt.user | quote }}
    email: {{ .Values.config.output.gitCrypt.email | quote }}
    repo: {{ .Values.config.output.gitCrypt.repo | quote }}
    single_repo: {{ .Values.config.output.gitCrypt.singleRepo }}
    users:
      {{ range .Values.config.output.gitCrypt.users }}
      - {{ . | quote }}
      {{ end }}
  {{ end }}
hooks:
  {{ if .Values.config.hooks.gitlabrepo.enabled }}
  gitlabrepo:
    type: {{ .Values.config.hooks.gitlabrepo.type | quote }}
    events:
      {{ range .Values.config.hooks.gitlabrepo.events }}
      - {{ . | quote }}
      {{ end }}
    remote_repo: {{ .Values.config.hooks.gitlabrepo.remoteRepo | quote }}
    privatekey: {{ .Values.config.hooks.gitlabrepo.privateKey | quote }}
    publickey: {{ .Values.config.hooks.gitlabrepo.publicKey | quote }}
    no_verify_host_key: {{ .Values.config.hooks.gitlabrepo.noVerifyHostKey }}
  {{ end }}
  {{ if .Values.config.hooks.exec.enabled }}
  exec:
    type: {{ .Values.config.hooks.exec.type | quote }}
    events:
      {{ range .Values.config.hooks.exec.events }}
      - {{ . | quote }}
      {{ end }}
    cmd: {{ .Values.config.hooks.exec.cmd | quote }}
    timeout: {{ .Values.config.hooks.exec.timeout }}
    async: {{ .Values.config.hooks.exec.async }}
  {{ end }}
  {{ if .Values.config.hooks.slackdiff.enabled }}
  slackdiff:
    type: {{ .Values.config.hooks.slackdiff.type | quote }}
    events:
      {{ range .Values.config.hooks.slackdiff.events }}
      - {{ . | quote }}
      {{ end }}
    token: {{ .Values.config.hooks.slackdiff.token | quote }}
    channel: {{ .Values.config.hooks.slackdiff.channel | quote }}
  {{ end }}
  {{ if .Values.config.hooks.xmppdiff.enabled }}
  xmppdiff:
    type: {{ .Values.config.hooks.xmppdiff.type | quote }}
    events:
      {{ range .Values.config.hooks.xmppdiff.events }}
      - {{ . | quote }}
      {{ end }}
    server: {{ .Values.config.hooks.xmppdiff.server | quote }}
    username: {{ .Values.config.hooks.xmppdiff.username | quote }}
    password: {{ .Values.config.hooks.xmppdiff.password | quote }}
    rooms:
      {{ range .Values.config.hooks.xmppdiff.rooms }}
      - {{ . | quote }}
      {{ end }}
  {{ end }}
source:
  default: {{ .Values.config.source.default | quote }}
  {{ if .Values.config.source.csv.enabled }}
  csv:
    file: {{ .Values.config.source.csv.file | quote }}
    delimiter: {{ .Values.config.source.csv.delimiter }}
    gpg: {{ .Values.config.source.csv.gpg }}
    {{ if .Values.config.source.csv.gpgPassword }}
    gpg_password: {{ .Values.config.source.csv.gpgPassword | quote }}
    {{ end }}
    map:
      {{ range $key, $value := .Values.config.source.csv.map }}
      {{ $key }}: {{ $value }}
      {{ end }}
    {{ if .Values.config.source.csv.varsMap }}
    vars_map:
      {{ range $key, $value := .Values.config.source.csv.varsMap }}
      {{ $key }}: {{ $value }}
      {{ end }}
    {{ end }}
  {{ end }}
  {{ if .Values.config.source.http.enabled }}
  http:
    url: {{ .Values.config.source.http.url | quote }}
    scheme: {{ .Values.config.source.http.scheme | quote }}
    secure: {{ .Values.config.source.http.secure }}
    {{ if .Values.config.source.http.user }}
    user: {{ .Values.config.source.http.user | quote }}
    {{ end }}
    {{ if .Values.config.source.http.pass }}
    pass: {{ .Values.config.source.http.pass | quote }}
    {{ end }}
    read_timeout: {{ .Values.config.source.http.readTimeout }}
    pagination: {{ .Values.config.source.http.pagination }}
    {{ if .Values.config.source.http.pagination }}
    pagination_key_name: {{ .Values.config.source.http.paginationKeyName | quote }}
    {{ end }}
    hosts_location: {{ .Values.config.source.http.hostsLocation | quote }}
    map:
      name: {{ .Values.config.source.http.map.name | quote }}
      ip: {{ .Values.config.source.http.map.ip | quote }}
      model: {{ .Values.config.source.http.map.model | quote }}
      group: {{ .Values.config.source.http.map.group | quote }}
    headers:
      {{ range $key, $value := .Values.config.source.http.headers }}
      {{ $key }}: {{ $value | quote }}
      {{ end }}
    {{ if .Values.config.source.http.varsMap }}
    vars_map:
      {{ range $key, $value := .Values.config.source.http.varsMap }}
      {{ $key }}: {{ $value | quote }}
      {{ end }}
    {{ end }}
  {{ end }}
  {{ if .Values.config.source.sql.enabled }}
  sql:
    adapter: {{ .Values.config.source.sql.adapter | quote }}
    database: {{ .Values.config.source.sql.database | quote }}
    table: {{ .Values.config.source.sql.table | quote }}
    {{ if .Values.config.source.sql.user }}
    user: {{ .Values.config.source.sql.user | quote }}
    {{ end }}
    {{ if .Values.config.source.sql.password }}
    password: {{ .Values.config.source.sql.password | quote }}
    {{ end }}
    {{ if .Values.config.source.sql.query }}
    query: {{ .Values.config.source.sql.query | quote }}
    {{ end }}
    with_ssl: {{ .Values.config.source.sql.withSsl }}
    {{ if .Values.config.source.sql.sslMode }}
    ssl_mode: {{ .Values.config.source.sql.sslMode | quote }}
    {{ end }}
    {{ if .Values.config.source.sql.sslCa }}
    ssl_ca: {{ .Values.config.source.sql.sslCa | quote }}
    {{ end }}
    {{ if .Values.config.source.sql.sslCert }}
    ssl_cert: {{ .Values.config.source.sql.sslCert | quote }}
    {{ end }}
    {{ if .Values.config.source.sql.sslKey }}
    ssl_key: {{ .Values.config.source.sql.sslKey | quote }}
    {{ end }}
    map:
      {{ range $key, $value := .Values.config.source.sql.map }}
      {{ $key }}: {{ $value | quote }}
      {{ end }}
    {{ if .Values.config.source.sql.varsMap }}
    vars_map:
      {{ range $key, $value := .Values.config.source.sql.varsMap }}
      {{ $key }}: {{ $value | quote }}
      {{ end }}
    {{ end }}
  {{ end }}
  {{ if .Values.config.source.jsonfile.enabled }}
  jsonfile:
    file: {{ .Values.config.source.jsonfile.file | quote }}
    gpg: {{ .Values.config.source.jsonfile.gpg }}
    {{ if .Values.config.source.jsonfile.gpgPassword }}
    gpg_password: {{ .Values.config.source.jsonfile.gpgPassword | quote }}
    {{ end }}
    map:
      {{ range $key, $value := .Values.config.source.jsonfile.map }}
      {{ $key }}: {{ $value | quote }}
      {{ end }}
    {{ if .Values.config.source.jsonfile.varsMap }}
    vars_map:
      {{ range $key, $value := .Values.config.source.jsonfile.varsMap }}
      {{ $key }}: {{ $value | quote }}
      {{ end }}
    {{ end }}
  {{ end }}
model_map:
  {{- range $key, $value := .Values.config.modelMap }}
  {{ $key }}: {{ $value | quote }}
  {{- end }}
groups:
  {{- range $group, $cfg := .Values.config.groups }}
  {{ $group }}:
    {{- if $cfg.usernamePlaceholder }}
    username: {{ $cfg.usernamePlaceholder | quote }}
    {{- end }}
    {{- if $cfg.passwordPlaceholder }}
    password: {{ $cfg.passwordPlaceholder | quote }}
    {{- end }}
    {{- if $cfg.vars }}
    vars:
      {{- range $varKey, $varValue := $cfg.vars }}
      {{ $varKey | snakecase }}: {{ $varValue | quote }}
      {{- end }}
    {{- end }}
    {{- if $cfg.models }}
    models:
      {{- range $model, $modelCfg := $cfg.models }}
      {{ $model }}:
        {{- if $modelCfg.username }}
        username: {{ $modelCfg.username | quote }}
        {{- end }}
        {{- if $modelCfg.password }}
        password: {{ $modelCfg.password | quote }}
        {{- end }}
        {{- if $modelCfg.vars }}
        vars:
          {{- range $varKey, $varValue := $modelCfg.vars }}
          {{ $varKey | snakecase }}: {{ $varValue | quote }}
          {{- end }}
        {{- end }}
      {{- end }}
    {{- end }}
    {{- range $key, $value := $cfg.extra }}
    {{ $key | snakecase }}: {{ $value | quote }}
    {{- end }}
  {{- end }}
models:
  {{- range $model, $cfg := .Values.config.models }}
  {{ $model }}:
    {{- if $cfg.username }}
    username: {{ $cfg.username | quote }}
    {{- end }}
    {{- if $cfg.password }}
    password: {{ $cfg.password | quote }}
    {{- end }}
    vars:
      {{- range $varKey, $varValue := $cfg.vars }}
      {{ $varKey | snakecase }}: {{ $varValue }}
      {{- end }}
  {{- end }}
{{- end -}}
