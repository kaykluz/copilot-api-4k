# Railway Deployment Guide for Copilot API

This guide will walk you through deploying your forked copilot-api repository to Railway.

## Prerequisites

- Railway account (sign up at https://railway.app)
- GitHub account with access to your fork (https://github.com/kaykluz/copilot-api-4k)
- GitHub Personal Access Token (you mentioned you already have this)
- GitHub Copilot subscription (individual, business, or enterprise)

## Deployment Methods

### Method 1: Deploy via Railway Dashboard (Recommended)

This is the easiest method and can be done entirely through the Railway web interface.

#### Step 1: Connect to Railway

1. Go to https://railway.app and sign in
2. Click **"New Project"**
3. Select **"Deploy from GitHub repo"**
4. Authorize Railway to access your GitHub account if you haven't already
5. Search for and select your repository: **kaykluz/copilot-api-4k**

#### Step 2: Configure Environment Variables

After selecting your repository, Railway will detect the Dockerfile automatically. Before deploying, you need to set up environment variables:

1. In your Railway project, click on your service
2. Go to the **"Variables"** tab
3. Add the following environment variable:
   - **Key**: `GH_TOKEN`
   - **Value**: Your GitHub Personal Access Token

**Important**: Make sure your GitHub token has the necessary permissions. The token should have at least `read:user` scope.

#### Step 3: Configure Port (Optional)

Railway will automatically detect port 4141 from the Dockerfile EXPOSE directive. If you need to change it:

1. Add another environment variable:
   - **Key**: `PORT`
   - **Value**: `4141` (or your preferred port)

#### Step 4: Deploy

1. Railway will automatically start building and deploying your application
2. Wait for the build to complete (this may take a few minutes)
3. Once deployed, Railway will provide you with a public URL

#### Step 5: Access Your API

1. Go to the **"Settings"** tab in your Railway service
2. Under **"Networking"**, you'll see your public domain (e.g., `your-app.railway.app`)
3. Your API will be available at:
   - OpenAI-compatible endpoint: `https://your-app.railway.app/v1/chat/completions`
   - Anthropic-compatible endpoint: `https://your-app.railway.app/v1/messages`
   - Models endpoint: `https://your-app.railway.app/v1/models`
   - Usage dashboard: `https://your-app.railway.app/usage`

### Method 2: Deploy via Railway CLI

If you prefer using the command line:

#### Step 1: Install Railway CLI

```bash
# Using npm
npm install -g @railway/cli

# Or using curl
curl -fsSL https://railway.app/install.sh | sh
```

#### Step 2: Login to Railway

```bash
railway login
```

This will open a browser window for authentication.

#### Step 3: Initialize Railway Project

Navigate to your repository directory and run:

```bash
cd /path/to/copilot-api-4k
railway init
```

Select **"Create a new project"** and give it a name.

#### Step 4: Set Environment Variables

```bash
railway variables set GH_TOKEN=your_github_token_here
```

#### Step 5: Deploy

```bash
railway up
```

This will build and deploy your application using the Dockerfile.

#### Step 6: Get Your Public URL

```bash
railway domain
```

This will generate a public domain for your service.

## Configuration Files Included

I've added two Railway configuration files to your repository:

1. **railway.json** - JSON format configuration
2. **railway.toml** - TOML format configuration

These files tell Railway to:
- Use the Dockerfile for building
- Pass the `GH_TOKEN` environment variable to the start command
- Restart the service on failure with up to 10 retries

## Environment Variables Reference

| Variable | Required | Description | Default |
|----------|----------|-------------|---------|
| `GH_TOKEN` | Yes | Your GitHub Personal Access Token | None |
| `PORT` | No | Port to listen on | 4141 |

## Additional Configuration Options

You can pass additional options to the start command by modifying the `startCommand` in the Railway configuration:

- **Verbose logging**: Add `--verbose` flag
- **Account type**: Add `--account-type business` or `--account-type enterprise`
- **Rate limiting**: Add `--rate-limit 30` (seconds between requests)
- **Custom port**: Add `--port 8080`

Example in railway.toml:
```toml
[deploy]
startCommand = "bun run dist/main.js start -g $GH_TOKEN --verbose --account-type business"
```

## Verifying Deployment

Once deployed, test your API:

### Check Available Models
```bash
curl https://your-app.railway.app/v1/models
```

### Test Chat Completion
```bash
curl -X POST https://your-app.railway.app/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-4o",
    "messages": [{"role": "user", "content": "Hello!"}]
  }'
```

### Check Usage
```bash
curl https://your-app.railway.app/usage
```

## Troubleshooting

### Build Fails

1. Check Railway build logs in the dashboard
2. Ensure your Dockerfile is correct
3. Verify that bun.lock and package.json are in the repository

### Authentication Issues

1. Verify your `GH_TOKEN` is set correctly in Railway variables
2. Make sure your GitHub token has the correct permissions
3. Check that you have an active GitHub Copilot subscription

### Service Crashes

1. Check Railway logs for error messages
2. Verify your GitHub Copilot subscription is active
3. Try adding `--verbose` flag to get more detailed logs

### Port Issues

1. Railway automatically assigns a PORT environment variable
2. The Dockerfile exposes port 4141 by default
3. Railway will handle port mapping automatically

## Updating Your Deployment

When you push changes to your GitHub repository:

1. Railway will automatically detect the changes
2. It will rebuild and redeploy your application
3. No manual intervention needed (continuous deployment)

To disable auto-deployment:
1. Go to your service settings in Railway
2. Under **"Deployments"**, toggle off **"Auto Deploy"**

## Cost Considerations

Railway offers:
- **Free tier**: $5 of usage per month (suitable for testing)
- **Hobby plan**: $5/month + usage (suitable for personal projects)
- **Pro plan**: $20/month + usage (for production use)

Your copilot-api service should be relatively lightweight, but costs depend on:
- Number of requests
- CPU and memory usage
- Network bandwidth

Monitor your usage in the Railway dashboard to avoid unexpected charges.

## Security Best Practices

1. **Never commit your GH_TOKEN** to the repository
2. Use Railway's environment variables for sensitive data
3. Consider adding authentication to your API endpoints
4. Monitor your GitHub Copilot usage to detect abuse
5. Set up rate limiting to prevent excessive API calls

## Next Steps

After deployment, you can:

1. **Use with OpenAI-compatible tools**: Point any OpenAI-compatible client to your Railway URL
2. **Integrate with Claude Code**: Follow the instructions in the main README
3. **Monitor usage**: Visit `https://your-app.railway.app/usage` for a dashboard
4. **Set up custom domain**: Configure a custom domain in Railway settings

## Support

- Railway Documentation: https://docs.railway.app
- Copilot API Issues: https://github.com/ericc-ch/copilot-api/issues
- Your Fork: https://github.com/kaykluz/copilot-api-4k

## Quick Reference Commands

```bash
# Login to Railway
railway login

# Link to existing project
railway link

# View logs
railway logs

# Set environment variable
railway variables set KEY=value

# Deploy
railway up

# Open in browser
railway open
```
