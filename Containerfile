# Context stage pointing to our new encapsulated features folder
FROM scratch AS ctx
COPY features /features

# Base Image
FROM quay.io/fedora-ostree-desktops/silverblue:42

### 1. DISTRIBUTE SYSTEM FILES
# Merges all 'system_files' directories across all features directly into the OS root
COPY --from=ctx /features/*/system_files/ /


### 2. MODIFICATIONS & BUILD LOOP
# Mounts the features folder, discovers all build scripts, sorts them alphanumerically,
# and runs them sequentially (05, 10, 15, 16, 21, 25, 30, etc.)
RUN --mount=type=bind,from=ctx,source=/features,target=/tmp/features \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    find /tmp/features/ -type f -path "*/build_files/*.sh" | sort | while read -r script; do \
        echo "🚀 Running feature script: $(basename "$script")"; \
        bash "$script" || exit 1; \
    done


### 3. GLOBAL ENVIRONMENT & PERMISSIONS ENFORCEMENTS
# Set timezone to Copenhagen
RUN ln -sf /usr/share/zoneinfo/Europe/Copenhagen /etc/localtime && \
    echo "Europe/Copenhagen" > /etc/timezone

# Uniformly enforce executable permissions on all target shell and python scripts
RUN chmod 755 /usr/libexec/*.sh /usr/libexec/*.py 2>/dev/null || true

# Compile dconf configurations
RUN dconf update

    
### 4. LINTING
# Verify final bootc image and contents are correct
RUN bootc container lint