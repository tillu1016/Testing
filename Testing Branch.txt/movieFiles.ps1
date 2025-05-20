# Box API credentials
$developerToken = "YOUR_DEVELOPER_TOKEN"

# Folder ID and new owner email
$folderId = "YOUR_FOLDER_ID"
$newOwnerEmail = "new.owner@example.com"

# Set the headers for the API request
$headers = @{
    "Authorization" = "Bearer $developerToken"
    "Content-Type"  = "application/json"
}

# Function to get user ID by email
function Get-UserIdByEmail($email) {
    $userSearchEndpoint = "https://api.box.com/2.0/users?filter_term=$email"
    $response = Invoke-RestMethod -Uri $userSearchEndpoint -Headers $headers -Method Get
    if ($response.total_count -eq 1) {
        return $response.entries[0].id
    } else {
        Write-Output "User not found or multiple users found."
        return $null
    }
}

# Get the user ID of the new owner
$newOwnerId = Get-UserIdByEmail -email $newOwnerEmail

if ($null -ne $newOwnerId) {
    # Box API endpoint for changing folder ownership
    $changeOwnerEndpoint = "https://api.box.com/2.0/folders/$folderId"
    
    # Prepare the request body
    $body = @{
        owned_by = @{
            id = $newOwnerId
        }
    } | ConvertTo-Json

    # Change folder ownership
    try {
        Invoke-RestMethod -Uri $changeOwnerEndpoint -Headers $headers -Method Put -Body $body
        Write-Output "Ownership of the folder has been transferred to $newOwnerEmail."
    } catch {
        Write-Output "Failed to change folder ownership: $_"
    }
} else {
    Write-Output "New owner email not found in Box."
}
