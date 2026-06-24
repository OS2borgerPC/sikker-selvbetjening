#!/bin/bash
set -e

echo "⚙️  Running Universal Service Auto-Enabler..."
echo "------------------------------------------------"

# Find all .service files inside the temporary features directory
# (Assumes the Containerfile mounts features to /tmp/features)
find /tmp/features -type f \( -name "*.service" -o -name "*.timer" \) | while read -r service_path; do
    service_name=$(basename "$service_path")
    
    # Scenario 1: User services (located under a .../systemd/user/ path)
    if [[ "$service_path" == *"/systemd/user/"* ]]; then
        echo "👤 Enabling User Service (Global): $service_name"
        systemctl --global enable "$service_name"

    # Scenario 2: The specific Power Scheduler workaround
    elif [[ "$service_name" == "power-scheduler.service" ]]; then
        echo "🔗 Applying manual symlink workaround for: $service_name"
        mkdir -p /etc/systemd/system/multi-user.target.wants/
        ln -sf "/etc/systemd/system/$service_name" "/etc/systemd/system/multi-user.target.wants/$service_name"

    # Scenario 3: Standard System services (located under .../systemd/system/ path)
    elif [[ "$service_path" == *"/systemd/system/"* ]]; then
        echo "🖥️  Enabling System Service: $service_name"
        systemctl enable "$service_name"
    fi
done

echo "------------------------------------------------"
echo "✅ All services initialized successfully."