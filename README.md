## Requirement
1. PHP >= 7.2 with native redis extension installed.
2. Redis
3. MySQL 5.7 with `utf8mb4` character sets
4. MongoDB 4.0
  
  
## Development with docker

1. **Installation**
    - Download Docker CE: https://docs.docker.com/install/
    - Clone this repository and change working directory into this project
    - For windows user, you should get use `bash` instead of using `cmd`, give a try with [cmder](http://cmder.net/) or `git bash`
    - Manage your docker container by `./dockerctl start` (`start`|`stop`|`status`|`restart`|`destroy`)
    - Setup environment variables:
        ```sh
        cp .env.docker .env
        ```
    - Start docker:
        ```
        ./dockerctl up -d --build (Only run this command when first time start project or rebuild image)
        ./dockerctl start
        ```
    - Composer install:
        ```
        ./dockerctl composer install -n --prefer-dist
        ```
    - Migration:
        ```
        ./dockerctl php artisan migrate:refresh --seed
        ```
    - API installation:
        ```
        ./dockerctl php artisan api:install
        ```
    - Test:
        ```
        ./dockerctl test
        ```
    - Your project will be available at `localhost:8000`, you can easily to change it through `DOCKER_APP_PORT` environment variable.
2. **Control your development environment with docker**
    - MySQL run in docker container with port `3306`, however, to prevent port conflict with host machine we using port `43306`, you can easily to change it through `DOCKER_MYSQL_PORT` environment variable:
      ```
      mysql -uhomestead -p -h 127.0.0.1 -P 43306
      ```
    - MongoDB run in docker container with port `27017`, on host machine is `37017` (`DOCKER_MONGODB_PORT`)
    - Redis run in docker container with port `6379`, on host machine is `7379` (`DOCKER_REDIS_PORT`)

## Development with vagrant by homestead
  - Our project has fully compatibility with homestead vagrant box, then just:
    ```
    cp .env.development .env
    composer require laravel/homestead
    php vendor/bin/homestead make
    vagrant up
    ```
  - After vagrant machine stay up, then install project dependency and migration:
    ```
    vagrant ssh
    cd /home/vagrant/code
    composer install -n --prefer-dist
    php artisan migrate:refresh --seed
    php artisan api:install
    ```
  - For everyday usage, read document about homestead: https://laravel.com/docs/5.6/homestead#daily-usage

## Development with valet
  - MacOS: https://laravel.com/docs/5.6/valet
  - Linux: https://cpriego.github.io/valet-linux
  - Windows (not recommended): https://github.com/cretueusebiu/valet-windows
  
_Enjoy!_
