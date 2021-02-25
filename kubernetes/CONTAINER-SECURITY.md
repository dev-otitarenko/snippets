# Running Containers as a Non-Root User

Run containers as non-root users, and block root containers from running, using the ***runAsUser*** setting.

```
containers:
- name: your-container
  image: cloudnatived/demo:hello
  securityContext:
    runAsUser: 1000
```

The value for runAsUser is a UID (a numerical user identifier). On many Linux systems, UID 1000 is assigned to the first non-root user created on the system, so it’s
generally safe to choose values of 1000 or above for container UIDs. It doesn’t matter whether or not a Unix user with that UID exists in the container, or even if there is an
operating system in the container; this works just as well with scratch containers.

Docker also allows you to specify a user in the Dockerfile to run the container’s process, but you needn’t bother to do this. It’s easier and more flexible to set the runA
sUser field in the Kubernetes spec. 

If a runAsUser UID is specified, it will override any user configured in the container image. If there is no runAsUser, but the container specifies a user, Kubernetes will run
it as that user. If no user is specified either in the manifest or the image, the container will run as root (which, as we’ve seen, is a bad idea).

For maximum security, you should choose a different UID for each container. That way, if a container should be compromised somehow, or accidentally overwrite data,
it only has permission to access its own data, and not that of other containers.

On the other hand, if you want two or more containers to be able to access the same data (via a mounted volume, for example), you should assign them the same UID.

# Blocking Root Containers

Run containers as non-root users, and block root containers from running, using the ***runAsNotRoot***: true setting.

```
containers:
- name: your-container
  image: cloudnatived/demo:hello
  securityContext:
    runAsNonRoot: true
```

When Kubernetes runs this container, it will check to see if the container wants to run as root. If so, it will refuse to start it. This will protect you against forgetting to set a non-root user in your containers, or running third-party containers that are configured to run as root.

If this happens, you’ll see the Pod status shown as CreateContainerConfigError, and when you kubectl describe the Pod, you’ll see this error "container has runAsNonRoot and image will run as root" 

# Read-Only file system

Another useful security context setting is ***readOnlyRootFilesystem***, which will prevent the container from writing to its own filesystem. It’s possible to imagine a con‐
tainer taking advantage of a bug in Docker or Kubernetes, for example, where writing to its filesystem could affect files on the host node. If its filesystem is read-only, that
can’t happen; the container will get an I/O error

```
containers:
- name: your-container
  image: cloudnatived/demo:hello
  securityContext:
    readOnlyRootFilesystem: true
```

# Disabling privilege escalation

This is a potential problem in containers, since even if the container is running as a regular user (UID 1000, for example), if it contains a setuid binary, that binary can
gain root privileges by default. To prevent this, set the **allowPrivilegeEscalation** field of the container’s security policy to false:

```
containers:
- name: your-container
  image: cloudnatived/demo:hello
  securityContext:
    allowPrivilegeEscalation: false
```

# Capabilities

Traditionally, Unix programs had two levels of privileges: normal and superuser. Normal programs have no more privileges than the user who runs them, while superuser
programs can do anything, bypassing all kernel security checks.

The Linux capabilities mechanism improves on this by defining various specific things that a program can do: load kernel modules, perform direct network I/O operations, access system devices, and so on. Any program that needs a specific privilege can be granted it, but no others.

For example, a web server that listens on port 80 would normally need to run as root to do this; port numbers below 1024 are considered privileged system ports. Instead,
the program can be granted the NET_BIND_SERVICE capability, which allows it to bind to any port, but gives it no other special privileges. The default set of capabilities for Docker containers is fairly generous. This is a pragmatic decision based on a trade-off of security against usability: giving containers no capabilities by default would require operators to set capabilities on many containers in order for them to run.

On the other hand, the principle of least privilege says that a container should have no capabilities it doesn’t need. Kubernetes security contexts allow you to drop any
capabilities from the default set, and add ones as they’re needed, like this example shows:

```
containers:
- name: demo
  image: cloudnatived/demo:hello
  securityContext:
    capabilities:
    drop: ["CHOWN", "NET_RAW", "SETPCAP"]
    add: ["NET_BIND_SERVICE"]
```    

The container will have the all capabilities removed, and the NET_BIND_SERVICE capability added.

The capability mechanism puts a hard limit on what processes inside the container can do, even if they’re running as root. Once a capability has been dropped at the
container level, it can’t be regained, even by a malicious process with maximum privileges.

# Pod Security Contexts

We’ve covered security context settings at the level of individual containers, but you can also set some of them at the Pod level:
```
apiVersion: v1
kind: Pod
...
spec:
  securityContext:
    runAsUser: 1000
    runAsNonRoot: false
    allowPrivilegeEscalation: false
```
These settings will apply to all containers in the Pod, unless the container overrides a given setting in its own security context.

P.S. **Set security contexts on all your Pods and containers. Disable privilege escalation and drop all capabilities. Add only the specific capabilities that a given container needs.**

# Pod Security Policies

Rather than have to specify all the security settings for each individual container or Pod, you can specify them at the cluster level using a PodSecurityPolicy resource. A
PodSecurityPolicy looks like this:
```
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: example
spec:
  privileged: false
  seLinux:
    rule: RunAsAny
  supplementalGroups:
    rule: RunAsAny
  runAsUser:
    rule: RunAsAny
  fsGroup:
    rule: RunAsAny
volumes:
- *
```
This simple policy blocks any privileged containers (those with the privileged flag set in their securityContext, which would give them almost all the capabilities of a
process running natively on the node).
