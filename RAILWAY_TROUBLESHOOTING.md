# Railway Deployment Troubleshooting Guide

## Error: "Failed to get Copilot token"

If you're seeing this error in your Railway deployment logs, it means the GitHub token you provided doesn't have the correct permissions to access the GitHub Copilot API.

### Root Cause

The copilot-api application requires a **GitHub Personal Access Token (PAT) with "Copilot Requests" permission**. A standard GitHub token (like `ghp_...`) or a classic PAT without this specific permission will fail to authenticate with the Copilot API.

### Solution: Create a Fine-Grained Personal Access Token

You need to create a **fine-grained Personal Access Token** with the **"Copilot Requests"** permission.

#### Step-by-Step Instructions

1. **Go to GitHub Token Settings**
   - Navigate to: https://github.com/settings/tokens?type=beta
   - Or go to: Settings → Developer settings → Personal access tokens → Fine-grained tokens

2. **Create New Token**
   - Click **"Generate new token"**
   - Give it a descriptive name (e.g., "Railway Copilot API")

3. **Configure Token Settings**
   - **Expiration**: Choose your preferred expiration (or "No expiration" for production)
   - **Repository access**: Select **"All repositories"** or specific repositories if needed
   
4. **Set Permissions**
   - Scroll down to **"Account permissions"** section
   - Find **"Copilot"** in the list
   - Set it to **"Read and write"** (or at minimum "Read")
   
   **Important**: The permission is called **"Copilot"** under "Account permissions", not "Repository permissions"

5. **Generate Token**
   - Click **"Generate token"** at the bottom
   - **Copy the token immediately** - you won't be able to see it again!
   - The token will look like: `github_pat_...` (fine-grained) or `ghp_...` (classic with correct scopes)

6. **Update Railway Environment Variable**
   - Go to your Railway project
   - Navigate to your service → **Variables** tab
   - Update the `GH_TOKEN` variable with your new token
   - Railway will automatically redeploy with the new token

### Alternative: Using the Auth Command

If you prefer to generate a token through the copilot-api's built-in authentication flow, you can:

1. **Run the auth command locally**:
   ```bash
   npx copilot-api@latest auth --show-token
   ```

2. **Follow the device code flow**:
   - The command will display a code and URL
   - Visit the URL and enter the code
   - Authorize the application

3. **Copy the generated token**:
   - The `--show-token` flag will display the GitHub token
   - Copy this token

4. **Set it in Railway**:
   - Add it as the `GH_TOKEN` environment variable in Railway

### Verification

After updating the token, check your Railway deployment logs. You should see:

```
[info] Using provided GitHub token
[info] Using VSCode version: 1.109.2
[info] Logged in as <your-github-username>
[info] Available models:
- gpt-4o
- gpt-4o-mini
- ...
```

If you still see "Failed to get Copilot token", verify:

1. ✅ Your GitHub account has an **active Copilot subscription**
2. ✅ The token has **"Copilot" permission** (Account permissions, not Repository)
3. ✅ The token hasn't expired
4. ✅ You copied the entire token without any extra spaces

## Other Common Issues

### Issue: Container Keeps Restarting

**Symptom**: Railway shows the service as "Deploying" but keeps restarting.

**Solution**: This is usually due to the authentication failure. Fix the token issue above.

### Issue: Port Not Exposed

**Symptom**: Service deploys successfully but you can't access the API.

**Solution**: 
1. Go to Railway service → **Settings** tab
2. Under **"Networking"**, click **"Generate Domain"**
3. Railway will create a public URL for your service

### Issue: Build Fails

**Symptom**: Build fails during Docker image creation.

**Possible causes**:
1. **Missing files**: Ensure `bun.lock` and `package.json` are in your repository
2. **Dockerfile issues**: Verify the Dockerfile is correct
3. **Build timeout**: Railway has build time limits on free tier

**Solution**: Check the build logs in Railway for specific error messages.

### Issue: High Memory Usage

**Symptom**: Service crashes with out-of-memory errors.

**Solution**: 
1. Railway free tier has memory limits
2. Consider upgrading to a paid plan if needed
3. Monitor usage at: Service → **Metrics** tab

## Testing Your Deployment

Once deployed successfully, test your API:

### 1. Check Available Models
```bash
curl https://your-app.railway.app/v1/models
```

Expected response:
```json
{
  "object": "list",
  "data": [
    {
      "id": "gpt-4o",
      "object": "model",
      ...
    }
  ]
}
```

### 2. Test Chat Completion
```bash
curl -X POST https://your-app.railway.app/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-4o",
    "messages": [{"role": "user", "content": "Hello!"}]
  }'
```

### 3. Check Usage Dashboard
Visit: `https://your-app.railway.app/usage`

This should show your Copilot usage statistics.

## Getting Help

If you're still experiencing issues:

1. **Check Railway Logs**:
   - Go to your service → **Deployments** tab
   - Click on the latest deployment
   - Review **Deploy Logs** for errors

2. **Enable Verbose Logging**:
   - Update your `railway.toml` or `railway.json`
   - Add `--verbose` flag to the start command:
     ```toml
     [deploy]
     startCommand = "bun run dist/main.js start -g $GH_TOKEN --verbose"
     ```

3. **Check GitHub Copilot Status**:
   - Visit: https://github.com/settings/copilot
   - Verify your subscription is active
   - Check usage limits

4. **Review Original Repository Issues**:
   - Check: https://github.com/ericc-ch/copilot-api/issues
   - Search for similar problems

## Security Best Practices

1. **Never commit tokens** to your repository
2. **Use Railway environment variables** for all sensitive data
3. **Rotate tokens regularly** for security
4. **Set token expiration** to limit exposure
5. **Monitor usage** to detect abuse
6. **Use rate limiting** in production:
   ```toml
   [deploy]
   startCommand = "bun run dist/main.js start -g $GH_TOKEN --rate-limit 30"
   ```

## Quick Reference: Token Permissions

| Token Type | Permission Required | Works? |
|------------|-------------------|--------|
| Classic PAT without Copilot scope | None | ❌ No |
| Classic PAT with `read:user` only | read:user | ❌ No |
| Fine-grained PAT without Copilot | None | ❌ No |
| Fine-grained PAT with Copilot (Read) | Copilot: Read | ✅ Yes |
| Fine-grained PAT with Copilot (Read+Write) | Copilot: Read+Write | ✅ Yes |

## Summary

The most common issue is **incorrect token permissions**. To fix:

1. Create a **fine-grained Personal Access Token** at https://github.com/settings/tokens?type=beta
2. Add **"Copilot"** permission (Account permissions section)
3. Set it as `GH_TOKEN` in Railway environment variables
4. Wait for automatic redeployment

Your service should now start successfully! 🚀
