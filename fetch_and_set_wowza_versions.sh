####
# Function to fetch and set Wowza streaming engine Docker versions
fetch_and_set_wowza_versions() {
    local url="https://registry.hub.docker.com/v2/repositories/wowzamedia/wowza-streaming-engine-linux/tags"
    local versions=()
    local max_retries=3
    local retry_count=0

    # Fetch versions with retry logic
    while [ "$url" != "null" ]; do
        response=$(curl -s -f "$url")
        if [ $? -ne 0 ]; then
            retry_count=$((retry_count + 1))
            if [ $retry_count -ge $max_retries ]; then
                echo "Error: Failed to fetch versions after $max_retries attempts"
                exit 1
            fi
            sleep 2
            continue
        fi

        # Process response in a single jq call
        versions+=( $(echo "$response" | jq -r '.results[] | .name') )
        url=$(echo "$response" | jq -r '.next')
    done

    # Early exit if no versions found
    if [ ${#versions[@]} -eq 0 ]; then
        echo "Error: No versions found"
        exit 1
    fi

    # Create menu items for available versions of wse docker images
    local menu_items=()
    for version in "${versions[@]}"; do
        menu_items+=("$version" "")
    done

    # Calculate menu dimensions
    local menu_height=$(( ${#menu_items[@]} / 2 + 7 ))
    menu_height=$(( menu_height > 20 ? 20 : menu_height ))
    local list_height=$(( ${#menu_items[@]} / 2 ))
    list_height=$(( list_height > 10 ? 10 : list_height ))

    # Display a box to select version to use
    engine_version=$(whiptail --title "Select Wowza Engine Version" \
                             --menu "Available Docker Wowza Engine Versions:" \
                             $menu_height 80 $list_height \
                             "${menu_items[@]}" 3>&1 1>&2 2>&3)

    if [ $? -ne 0 ] || [ -z "$engine_version" ]; then
        echo "No Wowza Engine version selected, exiting."
        exit 1
    fi

    # Prompt for Docker container name
    container_name=$(whiptail --inputbox "Enter the name for this WSE install (default: wse_${engine_version}):" \
                              8 78 "wse_${engine_version}" \
                              --title "Docker Container Name" 3>&1 1>&2 2>&3)

    # Check if user canceled or input is empty, set default name
    if [ $? -ne 0 ] || [ -z "$container_name" ]; then
        container_name="wse_${engine_version}"
    fi

    # Create container directory
    container_dir="$encp/$container_name"
    mkdir -p "$container_dir"
    # Define the nginx directory
    nginx="$container_dir/nginx"
    mkdir -p -m 777 "$swag" || {
        echo "Error: Failed to create container directory"
        exit 1
    }
}