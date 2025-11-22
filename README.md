# Retail Merchandise Management (RMM)

A lightweight **Rails 8** application for managing retail product data (Items, Prices, UPCs).  
Supports CSV import, background processing with **Sidekiq + Redis 7**, and a TailwindCSS admin interface.

---

## Features
- Admin: manage users, api_users
- Admin: manage items, item_prices, item_upcs
- Admin: import items, item_prices, item_ipcs
- Layout with **TailwindCSS**. 
- Background job with **Sidekiq**.
- Pagination with **Pagy**.
- User Authentication / Authorization with **Devise**.
- API access token with **JWT** standard.
- Manage API requests with API token, API Quota, and User active status.

---

## Tech Stack
- Ruby 3.4.7  
- Rails 8
- HTML/CSS/Stimulus JS, Rails API
- PostgreSQL
- Devise
- Sidekiq  
- Redis 7  
- TailwindCSS  
- Pagy
- JWT
 
---

## Install Ruby & Rails

Use the official multi-OS setup guide:  **https://gorails.com/setup**

---

## Install Redis 7.x.x (Sidekiq background job run on top of Redis cache)

#### macOS
```bash
brew install redis
brew services start redis
```

#### Ubuntu / WSL
```bash
sudo apt remove -y redis-server
sudo apt update
sudo apt install -y build-essential tcl
cd /tmp
wget https://download.redis.io/releases/redis-7.2.4.tar.gz
tar xzf redis-7.2.4.tar.gz
cd redis-7.2.4
make
sudo make install
redis-server --version
```

#### Windows

Use **WSL Ubuntu** and follow the Ubuntu installation steps.

---

## Project Setup

#### Start rails application
Open a terminal tab and run:
```bash
git clone git@github.com:niick7/RetailMerchandiseManagement.git
cd RetailMerchandiseManagement
bundle install
rails db:create
rails db:migrate
rails db:seed
rails server
```
Rails application URL: http://localhost:3000 (Use the credentials in the db/seeds.rb file to log in).

### Start background job
Start Redis - open another terminal tab and run:
```bash
redis-server
```

Start Sidekiq - open another terminal tab and run:
```bash
bundle exec sidekiq
```
Sidekiq URL: http://localhost:3000/sidekiq

---

## Author
**Dinh Nhan Vo (Nick Vo)**  
GitHub: https://github.com/niick7

---

## License
MIT License
