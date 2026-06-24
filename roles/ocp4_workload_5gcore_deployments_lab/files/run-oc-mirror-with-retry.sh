#!/bin/bash
#
# oc-mirror wrapper with retry logic for network failures
# Runs all three versions (418, 419, 420) and retries the entire sequence if any fail
# Returns 0 only if all mirrors succeed, 1 if any fail after 3 full retries
#

set -o pipefail

MAX_RETRIES=3
RETRY_DELAY=300  # 5 minutes between retries
REGISTRY="$1"

# Function to run all three oc-mirror operations
run_all_mirrors() {
    local attempt=$1
    local all_success=true

    echo "=== Attempt ${attempt}/${MAX_RETRIES}: Starting full oc-mirror sequence ==="

    # Mirror 4.18
    echo "--- Mirroring OCP 4.18 ---"
    oc-mirror --parallel-images=10 --v2 \
        --workspace file:///root/workspace-418/ \
        --config=/root/imageset-mirror-core-418.yaml \
        docker://${REGISTRY} \
        2>&1 | tee -a /root/mirroring-418.log

    # Check for errors (matches original async check pattern)
    if grep -q 'some errors occurred during the mirroring' /root/mirroring-418.log; then
        echo "ERROR: oc-mirror 4.18 - some errors occurred during the mirroring"
        all_success=false
    fi

    # Mirror 4.19
    echo "--- Mirroring OCP 4.19 ---"
    oc-mirror --parallel-images=10 --v2 \
        --workspace file:///root/workspace-419/ \
        --config=/root/imageset-mirror-core-419.yaml \
        docker://${REGISTRY} \
        2>&1 | tee -a /root/mirroring-419.log

    # Check for errors (matches original async check pattern)
    if grep -q 'some errors occurred during the mirroring' /root/mirroring-419.log; then
        echo "ERROR: oc-mirror 4.19 - some errors occurred during the mirroring"
        all_success=false
    fi

    # Mirror 4.20
    echo "--- Mirroring OCP 4.20 ---"
    oc-mirror --parallel-images=10 --v2 \
        --workspace file:///root/workspace-420/ \
        --config=/root/imageset-mirror-core-420.yaml \
        docker://${REGISTRY} \
        2>&1 | tee -a /root/mirroring-420.log

    # Check for errors (matches original async check pattern)
    if grep -q 'some errors occurred during the mirroring' /root/mirroring-420.log; then
        echo "ERROR: oc-mirror 4.20 - some errors occurred during the mirroring"
        all_success=false
    fi

    if [ "$all_success" = true ]; then
        return 0
    else
        return 1
    fi
}

# Main execution - retry the entire sequence up to MAX_RETRIES times
for attempt in $(seq 1 $MAX_RETRIES); do
    if run_all_mirrors "$attempt"; then
        echo "=== SUCCESS: All oc-mirror operations completed without errors ==="
        exit 0
    else
        if [ $attempt -lt $MAX_RETRIES ]; then
            echo "=== RETRY: Waiting ${RETRY_DELAY} seconds before retrying entire sequence ==="
            sleep $RETRY_DELAY
        fi
    fi
done

echo "=== FAILED: oc-mirror sequence failed after ${MAX_RETRIES} full attempts ==="
exit 1
