#!/bin/bash

# --- CONFIGURATION ---
INSTANCE_ID="i-0123456789abcdef0"
SNAPSHOT_ID="snap-0987654321fedcba"
DEVICE_NAME="/dev/sdf"  # Change to /dev/sdh, etc., if needed
VOLUME_TYPE="gp3"

echo "Step 1: Retrieving Availability Zone for $INSTANCE_ID..."
AZ=$(aws ec2 describe-instances \
    --instance-ids $INSTANCE_ID \
    --query "Reservations[*].Instances[*].Placement.AvailabilityZone" \
    --output text)

echo "Instance is in zone: $AZ"

echo "Step 2: Creating volume from snapshot $SNAPSHOT_ID..."
VOLUME_ID=$(aws ec2 create-volume \
    --availability-zone $AZ \
    --snapshot-id $SNAPSHOT_ID \
    --volume-type $VOLUME_TYPE \
    --query "VolumeId" \
    --output text)

echo "Created Volume: $VOLUME_ID"

echo "Step 3: Waiting for volume to become 'available'..."
aws ec2 wait volume-available --volume-ids $VOLUME_ID
echo "Volume is ready."

echo "Step 4: Attaching volume to instance..."
aws ec2 attach-volume \
    --volume-id $VOLUME_ID \
    --instance-id $INSTANCE_ID \
    --device $DEVICE_NAME

echo "Success! Volume $VOLUME_ID is being attached to $INSTANCE_ID as $DEVICE_NAME."
