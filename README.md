# Constants

## Goals
- a single repo from which we can publish a Ruby gem as well as a Node package (and maybe others someday)
- a single source of truth — such as one or more JSON files — with a build process to generate the gem and the package from it
- automated deploys to the respective package managers' repositories

## Desired usage in consuming apps

### Ruby

```ruby
require 'anandaroop/constants'

puts Anandaroop::Constants::Math::PI
```

### Javascript

```js
import { Math } from "@anandaroop/constants"

console.log(Math.PI)
```

## Workflow for updating and publishing

```sh
# update the source of truth
vi source-of-truth/math.json

# rebuild the packages in all languages
rake build

# publish new versions to the package mgr repos
rake publish
