# Oxidized Helm Chart

这个 Chart 基于当前目录下已经整理好的 Kubernetes 清单封装而成，目标是保留现有资源命名、安全上下文和 Secret 分层方式，同时把高频可变项收进 `values.yaml`。

## 目录

- `Chart.yaml`：Chart 元信息
- `values.yaml`：默认参数
- `values.schema.json`：values 基础校验和编辑器提示
- `templates/`：Helm 模板

## 默认设计

- 资源名默认保持为 `oxidized`
- `ConfigMap` 名称默认是 `oxidized-config`
- PVC 默认是 `oxidized-data`
- SSH Secret 默认是 `oxidized-ssh-keys`
- Runtime Secret 默认是 `oxidized-runtime`
- 默认不开启 `Ingress`
- 默认不开启 `NetworkPolicy`
- 默认创建占位 Secret；生产环境建议用 `sshSecret.existingSecret` / `runtimeSecret.existingSecret` 引用已有 Secret
- 如果关闭 `serviceAccount.create` 且未指定 `serviceAccount.name`，会回退到 Kubernetes 默认 `default` ServiceAccount
- 如果关闭 `persistence.enabled`，数据目录会退回到 `emptyDir`
- PVC StorageClass 按 `persistence.storageClass`、`persistence.storageClassName`、`global.defaultStorageClass`、`global.storageClass` 优先级解析，其中 `storageClassName` 和 `global.storageClass` 仅作兼容别名
- 支持 Bitnami 风格的 `global.imageRegistry`、`global.imagePullSecrets`、`global.defaultStorageClass`
- Oxidized 主配置已按字段拆分到 `values.yaml` 的 `config.*` 下，并在 `templates/configmap.yaml` 中逐项渲染
- 支持 `commonLabels`、`commonAnnotations`、`podLabels`、`podAnnotations`、`nodeSelector`、`tolerations`、`affinity` 等常见 Helm Chart 参数
- 支持 `extraEnv`、`extraVolumes`、`extraVolumeMounts`、`extraInitContainers`、`sidecars`、`lifecycle`、`topologySpreadConstraints` 等扩展入口
- ConfigMap 或由 Chart 创建的 Secret 变更时，会通过 checksum 注解触发 Deployment 滚动
- 默认包含 `helm test` 连接测试，可通过 `tests.enabled` 关闭
- 主容器默认不强制设置 `securityContext`，以兼容 `oxidized/oxidized` 镜像内部的 runit/supervise 初始化逻辑；如需收紧权限，请先在测试环境验证
- 主容器默认不覆盖 `command`/`args`，让 `oxidized/oxidized` 镜像按默认入口启动
- 主容器安全上下文变量采用 Bitnami 风格的 `containerSecurityContext`；旧的 `securityContext` 仅作为兼容别名保留

## 安装方式

先准备一个覆盖文件，例如 `values-prod.yaml`：

```yaml
image:
  tag: "0.36.0"

sshSecret:
  create: false
  existingSecret: oxidized-ssh-keys

runtimeSecret:
  create: false
  existingSecret: oxidized-runtime
  secretKeys:
    deviceUsernameKey: OXIDIZED_DEVICE_USERNAME
    devicePasswordKey: OXIDIZED_DEVICE_PASSWORD
    netboxApiTokenKey: NETBOX_API_TOKEN
    readonlyDeviceUsernameKey: OXIDIZED_READONLY_DEVICE_USERNAME
    readonlyDevicePasswordKey: OXIDIZED_READONLY_DEVICE_PASSWORD

ingress:
  enabled: true
  className: nginx
  hosts:
    - host: oxidized.example.com
      paths:
        - path: /
          pathType: Prefix

networkPolicy:
  enabled: true
  ingress:
    enabled: true
    fromAllNamespaces: true
  egress:
    enabled: true
```

安装：

```bash
helm upgrade --install oxidized ./charts/oxidized \
  -n oxidized \
  --create-namespace \
  -f values-prod.yaml
```

测试：

```bash
helm test oxidized -n oxidized
```

## Secret 策略

更推荐在 Chart 外部先创建 Secret，再通过以下值引用：

```yaml
sshSecret:
  create: false
  existingSecret: oxidized-ssh-keys

runtimeSecret:
  create: false
  existingSecret: oxidized-runtime
  secretKeys:
    deviceUsernameKey: OXIDIZED_DEVICE_USERNAME
    devicePasswordKey: OXIDIZED_DEVICE_PASSWORD
    netboxApiTokenKey: NETBOX_API_TOKEN
    readonlyDeviceUsernameKey: OXIDIZED_READONLY_DEVICE_USERNAME
    readonlyDevicePasswordKey: OXIDIZED_READONLY_DEVICE_PASSWORD
```

`sshSecret` 和 `runtimeSecret` 的处理方式现在接近 PostgreSQL Chart 中常见的 `existingSecret`/`secretKeys` 模式：

- `sshSecret.create: true`：由 Chart 创建 SSH Secret，数据来自 `sshSecret.data`
- `sshSecret.existingSecret: oxidized-ssh-keys`：引用外部 SSH Secret，Chart 不创建 SSH Secret
- `runtimeSecret.create: true`：由 Chart 创建 Secret，数据来自 `runtimeSecret.data`
- `runtimeSecret.existingSecret: oxidized-runtime`：引用外部 Secret，Chart 不创建 Secret
- `runtimeSecret.secretKeys.*`：声明外部 Secret 中每个字段对应的 key 名

`OXIDIZED_DEVICE_USERNAME` / `OXIDIZED_DEVICE_PASSWORD` 是 Oxidized 默认登录网络设备的账号密码；`OXIDIZED_READONLY_DEVICE_USERNAME` / `OXIDIZED_READONLY_DEVICE_PASSWORD` 用于需要按 group 覆盖的网络设备只读账号。它们都不是 Web UI 登录信息。

默认 `values.yaml` 中敏感字段使用类型正确的空值，例如 `""`，不再使用 `REPLACE_WITH_*`。如果只是本地测试，也可以让 Chart 帮你创建 Secret：

```yaml
sshSecret:
  create: true
  data:
    id_rsa: |
      -----BEGIN OPENSSH PRIVATE KEY-----
      ...
      -----END OPENSSH PRIVATE KEY-----
    id_rsa_pub: "ssh-rsa AAAA..."
    known_hosts: "git.example.com ssh-ed25519 AAAA..."

runtimeSecret:
  create: true
  data:
    deviceUsername: "readonly"
    devicePassword: "readonly-password"
    netboxApiToken: "netbox-token"
    readonlyDeviceUsername: "readonly"
    readonlyDevicePassword: "readonly-password"
```

生产环境更推荐使用外部 Secret，不建议把真实私钥或真实 Token 提交进版本库。

## 配置方式

Chart 现在采用字段化配置模式：

- 在 `values.yaml` 里通过 `config.*` 分别定义各个配置项
- `config.existingConfigmap` 可引用外部 ConfigMap，类似 Bitnami PostgreSQL 的 `primary.existingConfigmap`
- `config.configuration` 可直接覆盖完整配置，类似 Bitnami PostgreSQL 的 `primary.configuration`
- 默认字段化配置由 `templates/_configuration.tpl` 生成，再由 `templates/configmap.yaml` 以 `config: |-` 块文本输出
- 敏感占位符仍然通过 `runtimeSecret` 在启动时注入

这样你可以在环境专用 values 文件里按字段覆盖，而不是整段替换配置文本。

查看 ConfigMap 时，`kubectl get cm oxidized-config -o yaml` 可能会把 `data.config` 重新序列化成带 `\n` 的 quoted string，这是 kubectl 的展示方式，不代表容器内文件也是一行。建议使用下面的命令查看实际配置内容：

```bash
kubectl -n oxidized get cm oxidized-config -o jsonpath='{.data.config}'
kubectl -n oxidized exec deploy/oxidized -- cat /home/oxidized/.config/oxidized/config
```

### 固定参数

以下配置会默认渲染到 Oxidized 配置文件中，并提供默认值：

- `config.core.*`：全局用户名、密码占位符、默认 model、interval、timeout、timelimit、threads、prompt、pid 等
- `config.vars.removeSecret`：默认开启配置脱敏
- `config.crash.*` 和 `config.stats.*`：崩溃目录和统计历史大小
- `config.input.default`、`config.output.default`、`config.source.default`：默认使用的 input、output 和 source
- `config.modelMap`、`config.groups`、`config.models`：设备模型、组和模型变量映射

### 可选配置

以下配置通过 `enabled` 控制是否渲染：

- `config.logger.enabled`：启用 logger appenders 配置
- `config.rest.enabled`：启用旧版 `rest` 配置，官方已标记为 deprecated
- `config.extensions.oxidizedWeb.enabled`：启用 `oxidized-web` 扩展，默认开启
- `config.input.ssh.enabled` 和 `config.input.telnet.enabled`：启用 SSH/Telnet input 配置
- `config.output.git.enabled`、`file.enabled`、`http.enabled`、`gitCrypt.enabled`：启用不同 output
- `config.source.csv.enabled`、`http.enabled`、`sql.enabled`、`jsonfile.enabled`：启用不同 source
- `config.hooks.*.enabled`：启用 Git repo、exec、Slack diff、XMPP diff 等 hook
- `config.vars.metadata.enabled`、`enable.enabled`、`outputStoreMode.enabled`：启用对应全局变量

## 建议

- 上线前固定 `image.tag`
- `networkPolicy.enabled` 只打开总开关，实际只会渲染已启用的 `ingress.enabled` 或 `egress.enabled` 子规则
- 将 `networkPolicy.egress.cidr` 收紧到真实地址范围
- 将 `config.*` 中和环境绑定的内容收敛，并优先把敏感值继续保留在 Secret 中
