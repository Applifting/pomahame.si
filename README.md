# pomuzeme.si
<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-4-orange.svg?style=flat-square)](#contributors-)
<!-- ALL-CONTRIBUTORS-BADGE:END -->

An open-source platform which aims to simplify and streamline the coordination of volunteers. Through the platform, local organizations can reach volunteers in the area where assistance is needed. This project originated as a voluntary initiative in connection with the COVID-19 infection.

## Getting Started

The application is an MVC monolith written in the RubyOnRails framework. On Frontend we are using common "bootstrap" based frameworks such as Bulma or Materialize design.

### Local development environment

#### Required software

1. Ruby 2.6.3
2. NodeJS
3. yarn (`sudo npm install -g yarn`)
4. PostgreSQL
5. Redis

#### Steps to get it running

1. `git clone git@github.com:Applifting/pomuzeme.si.git && cd pomuzeme.si`
2. `bundle install`
3. `rake db:create && rake db:migrate` Note: avoid `db:setup` as there is an `db:create` hook that is required,
   in order to have postgres extension.
4. `yarn install`
5. `rails server`

## Contribution

In case you decide to contribute in this project, we will be very happy and we appreciate your help. Feel free to:

1. Check out open [issues](https://github.com/Applifting/pomuzeme.si/issues). Ideally, choose from the ones that are labeled as `ready for dev`. If you are going to contribute code, read our [architecture guideline](./doc/architecture.md).
2. Assign your self to the selected issue
3. Write estimate delivery time into issue comment (preferably with ping to [@snopedom](https://github.com/snopedom))
4. Create a new branch from `master` where work will be done
5. After work is done please create new pull request into `master`
6. Wait for review and PR approval (PR should be approved by 2 other developers, at least one from Applifting)
7. After merge work is DONE! Thank you! :heart:

If you have any questions about development or issue description, feel free to ask the author of the issue in comments.

## Deployment

At this moment application is deployed on Heroku cloud service. We have two environments, `staging` and `production`.

**Deployment to staging** - [staging.pomuzemesi.cz](https://staging.pomuzemesi.cz)

Staging deployment is realised by automatic deploy hook which is triggered when code into `master` is merged (pushed).

**Deployment to production** - [www.pomuzemesi.cz](https://pomuzemesi.cz)

Production deployment is done by authorized developers from Applifting. Deploys are made regularly, each time a new functionality is created. If you need to put something into production contact:

[**Dominik Snopek**](https://github.com/snopedom) - _Development coordinator_ - dominik.snopek@applifting.cz

[**Martin Hanzík**](https://github.com/martinhanzik) - _DevOps_ - martin.hanzik@applifting.cz

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details

## Authors

Authors of this platform are awesome guys and girls from [Applifting](www.applifting.io). We could not do it without our Contributors that are listed below. Thanks from the bottom of our hearts! :heart:

## Contributors

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tr>
    <td align="center"><a href="http://www.applifting.cz"><img src="https://avatars2.githubusercontent.com/u/10887101?v=4" width="100px;" alt=""/><br /><sub><b>Dominik Snopek</b></sub></a><br /><a href="https://github.com/Applifting/pomuzeme.si/commits?author=snopedom" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/landovsky"><img src="https://avatars1.githubusercontent.com/u/435847?v=4" width="100px;" alt=""/><br /><sub><b>landovsky</b></sub></a><br /><a href="#ideas-landovsky" title="Ideas, Planning, & Feedback">🤔</a> <a href="#projectManagement-landovsky" title="Project Management">📆</a> <a href="#business-landovsky" title="Business development">💼</a></td>
    <td align="center"><a href="https://github.com/arthurwozniak"><img src="https://avatars1.githubusercontent.com/u/1984961?v=4" width="100px;" alt=""/><br /><sub><b>Kamil Hanus</b></sub></a><br /><a href="https://github.com/Applifting/pomuzeme.si/commits?author=arthurwozniak" title="Code">💻</a> <a href="https://github.com/Applifting/pomuzeme.si/pulls?q=is%3Apr+reviewed-by%3Aarthurwozniak" title="Reviewed Pull Requests">👀</a></td>
    <td align="center"><a href="https://github.com/martinhanzik"><img src="https://avatars2.githubusercontent.com/u/107980?v=4" width="100px;" alt=""/><br /><sub><b>Martin Hanzík</b></sub></a><br /><a href="#infra-martinhanzik" title="Infrastructure (Hosting, Build-Tools, etc)">🚇</a> <a href="https://github.com/Applifting/pomuzeme.si/commits?author=martinhanzik" title="Code">💻</a> <a href="https://github.com/Applifting/pomuzeme.si/pulls?q=is%3Apr+reviewed-by%3Amartinhanzik" title="Reviewed Pull Requests">👀</a></td>
  </tr>
</table>

<!-- markdownlint-enable -->
<!-- prettier-ignore-end -->
<!-- ALL-CONTRIBUTORS-LIST:END -->