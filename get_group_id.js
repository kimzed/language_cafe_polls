// Quick script to get group ID from invite code
// Run: node get_group_id.js

const code = "JgHCqQn3mxn2sxW7rexXip";

// The session is stored in the Docker volume, we need to access the API differently
// Let's try the simulate endpoint which might give us more access

fetch("http://localhost:3000/simulate", {
    method: "POST",
    headers: {"Content-Type": "application/json"},
    body: JSON.stringify({
        action: "groupGetInviteInfo",
        params: [code]
    })
})
.then(r => r.json())
.then(console.log)
.catch(console.error);
