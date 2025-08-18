# Backend Environment Configuration

This Rails application uses environment variables to handle different deployment environments.

## Environment Variables

### Required for Production

```bash
# API and Frontend URLs
API_BASE_URL=https://api.yourdomain.com
FRONTEND_URL=https://yourdomain.com

# Rails Master Key (for credentials)
RAILS_MASTER_KEY=your_master_key_here

# Database URL (if using external database)
DATABASE_URL=postgresql://username:password@host:port/database_name

# Log Level
RAILS_LOG_LEVEL=info
```

### Optional for Production

```bash
# Serve static files
RAILS_SERVE_STATIC_FILES=true

# Log to STDOUT (for containerized deployments)
RAILS_LOG_TO_STDOUT=true
```

## Configuration Files

### Development (config/environments/development.rb)

- Uses localhost URLs by default
- Overrides can be set via environment variables

### Production (config/environments/production.rb)

- Requires `API_BASE_URL` and `FRONTEND_URL` environment variables
- Uses SSL/TLS by default
- Optimized for production performance

## How It Works

The application configuration is set in `config/application.rb`:

```ruby
config.x.api_base_url = ENV.fetch('API_BASE_URL', 'http://localhost:3000')
config.x.frontend_url = ENV.fetch('FRONTEND_URL', 'http://localhost:5173')
```

These values are then used throughout the application:

```ruby
# In controllers
redirect_to "#{Rails.application.config.x.frontend_url}/invitation-accepted"

# In mailers
config.action_mailer.default_url_options = { host: ENV.fetch('FRONTEND_URL') }
```

## Deployment Examples

### Heroku

```bash
heroku config:set API_BASE_URL=https://your-api.herokuapp.com
heroku config:set FRONTEND_URL=https://yourdomain.com
```

### Docker

```bash
docker run -e API_BASE_URL=https://api.yourdomain.com \
           -e FRONTEND_URL=https://yourdomain.com \
           -e RAILS_MASTER_KEY=your_key \
           your-app
```

### Traditional Server

```bash
export API_BASE_URL=https://api.yourdomain.com
export FRONTEND_URL=https://yourdomain.com
export RAILS_MASTER_KEY=your_key
rails server -e production
```

## Security Notes

- Never commit `.env` files to version control
- Use encrypted credentials for sensitive data (Gmail passwords, etc.)
- Keep your `master.key` secure and separate from your code
- Use HTTPS in production for all URLs
