#!/usr/bin/env bash
# inventory all subscriptions you have access to (very common in enterprises)

set -euo pipefail

command -v jq >/dev/null || { echo "Install jq: sudo apt install jq"; exit 1; }
command -v timeout >/dev/null || { echo "Install coreutils: sudo apt install coreutils"; exit 1; }

output_dir="azure_full_inventory_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$output_dir"

echo "Collecting enabled subscriptions..."
subscriptions=$(az account list --query "[?state=='Enabled'].{name:name, id:id}" --output tsv)

[ -z "$subscriptions" ] && { echo "No enabled subs."; exit 1; }

total_resources=0
processed=0
skipped_empty=0

echo "Found:"
echo "$subscriptions" | awk '{print "  - " $1 " (" $2 ")"}'

echo ""
echo "Output → $output_dir/"
echo "────────────────────────────────────────"

while IFS=$'\t' read -r sub_name sub_id; do
    ((++processed))
    echo ""
    echo "[$processed] $sub_name ($sub_id)"

    safe_name=$(echo "$sub_name" | tr -s '[:space:]' '_' | tr -cd '[:alnum:]_-')
    output_file="${output_dir}/inventory_${safe_name}_${sub_id:0:8}.csv"
    err_log="${output_file}.err"

    echo "  Checking resource count (with retries)..."

    count=""
    attempts=0
    max_attempts=3

    while [ $attempts -lt $max_attempts ] && [ -z "$count" ]; do
        ((++attempts))
        echo "    Attempt $attempts/$max_attempts..."
        count=$(az resource list --subscription "$sub_id" --query 'length([])' --output tsv) && break
        echo "    → Failed or hung on attempt $attempts. Retrying in 10s..."
        sleep 10
    done

    if [ -z "$count" ]; then
        echo "  → Count query failed after $max_attempts attempts. Skipping."
        az resource list --subscription "$sub_id" --query 'length([])' --output tsv --debug > "${err_log}.debug" 2>&1
        echo "  Debug saved to ${err_log}.debug"
        continue
    fi

    echo "  → Count result: $count"

    if [ "$count" = "0" ]; then
        echo "  → 0 resources → skipping."
        ((++skipped_empty))
        continue
    fi

    echo "  Exporting full list (timeout 180s)..."
    json_temp="${output_file}.json.tmp"

    if ! timeout 180 az resource list \
        --subscription "$sub_id" \
        --query '[].{Name:name, Type:type, ResourceGroup:resourceGroup, Location:location, SubscriptionId:subscriptionId, ID:id}' \
        --output json > "$json_temp" 2>"$err_log"; then
        echo "  → Export timed out/failed (see $err_log)."
        rm -f "$json_temp"
        continue
    fi

    if [ -s "$json_temp" ]; then
        jq -r 'if length == 0 then empty else (.[0] | keys_unsorted | join(",")), (.[] | [.[]] | join(",")) end' \
            < "$json_temp" > "$output_file" 2>>"$err_log"

        if [ -s "$output_file" ]; then
            line_count=$(wc -l < "$output_file")
            res_count=$((line_count - 1))
            total_resources=$((total_resources + res_count))
            echo "  → $res_count resources exported"
        else
            echo "  → jq failed or empty output"
        fi
        rm -f "$json_temp"
    else
        echo "  → No data returned (check $err_log)"
    fi

done <<< "$subscriptions"

echo ""
echo "────────────────────────────────────────"
echo "Processed $processed subs | Skipped $skipped_empty empty subs | Total resources: $total_resources"
echo "Files saved in: $output_dir/"
