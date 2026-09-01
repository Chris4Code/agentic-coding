-----------------------------------------------------------------------------------------------------

````
What are CI/CD alternatices to GH actions that can be used website (e.g. Github, Gitstack, ...) agnostic? Please answer in English language.
````

-----------------------------------------------------------------------------------------------------

Several platform-agnostic CI/CD tools connect to virtually any Git hosting provider (GitHub, GitLab, Bitbucket, self-hosted Git, Gitea, etc.).

---

### Managed Cloud & SaaS Options

* **CircleCI:** Connects directly via OAuth or webhooks to GitHub, Bitbucket, or GitLab. It offers strong parallelism, caching, and a managed runner setup.
* **Travis CI:** One of the earliest hosted CI/CD platforms. Supports GitHub, Bitbucket, GitLab, and custom Git servers via webhooks.
* **Buildkite:** Uses a hybrid model. Buildkite manages the pipeline UI and orchestration in the cloud, while you run lightweight build agents on your own infrastructure. It works with any Git repository.

---

### Open-Source & Self-Hosted Options

* **Woodpecker CI / Drone CI:** Container-native CI engines configured with straightforward `.woodpecker.yml` or `.drone.yml` files. They include built-in plugins for GitHub, GitLab, Bitbucket, Gitea, and custom Git servers.
* **Jenkins:** The industry standard for self-hosted CI/CD. Highly customizable through its massive plugin ecosystem, allowing it to integrate with any version control system.
* **JetBrains TeamCity:** Offers both cloud-hosted and self-hosted versions with native Git integration. Supports Kotlin DSL or a GUI for pipeline configuration.

---

### Modern Code-as-Driver Frameworks

* **Dagger:** A container-native engine that lets you write your CI/CD pipelines in real programming languages (Go, Python, TypeScript) rather than YAML. Because Dagger runs locally or inside containers, it is completely provider-agnostic and can be executed from any Git server or local machine.

---

### Feature Summary

| Tool | Deployment Model | Best For |
| --- | --- | --- |
| **CircleCI** | Cloud / Self-hosted Runners | SaaS-first pipelines with fast build caching |
| **Woodpecker / Drone** | Self-Hosted | Lightweight, Docker-native pipeline setups |
| **Jenkins** | Self-Hosted | Complex enterprise setups needing extreme customization |
| **Buildkite** | Hybrid (SaaS UI + Local Runners) | Security-conscious teams wanting local build control |
| **Dagger** | Programmatic / Local / Any CI | Writing pipelines in Python/Go/TS instead of YAML |

-----------------------------------------------------------------------------------------------------

````
Is Dagger the only solution offering programming languages to manage CI/CD tasks? Are there solution using a real - non yaml based - DSL (with usual IDE integration like augmentation, etc) for CI/CD?
````

-----------------------------------------------------------------------------------------------------
No, **Dagger is not the only solution**, though it is currently the most popular general-purpose option for writing pipelines directly in multi-language SDKs (Go, Python, TypeScript).

Several other systems use **real, non-YAML DSLs** written in general-purpose programming languages. These give you full IDE integration—such as type checking, static code analysis, step-by-step debugging, and code completion.

---

### Non-YAML DSL CI/CD Solutions

* **JetBrains TeamCity (Kotlin DSL):**
TeamCity provides a native, statically typed **Kotlin DSL** as a first-class alternative to YAML or GUI builders. Because Kotlin was developed by JetBrains, the IDE experience (IntelliJ IDEA) offers deep autocompletion, refactoring, and code generation. It generates full pipeline configurations that live in your repository.
* **Pulumi / CDK-Style Automation API (Build-your-own CI):**
While traditionally used for Infrastructure-as-Code (IaC), tools like **Pulumi** allow you to write deployment pipelines using TypeScript, Python, Go, or C#. You can wrap these scripts inside lightweight container jobs (like a single step in a simple runner) to eliminate YAML logic entirely.
* **Jenkins (Groovy DSL):**
Jenkins Pipelines rely on **Groovy** for `Jenkinsfile` configurations. Unlike simple declarative syntax, scripted pipelines allow full programming constructs (loops, conditionals, functions, class imports). IDEs like VS Code and IntelliJ support the Jenkins Pipeline DSL via plugins to provide syntax highlighting and autocompletion.
* **Fluent CI (TypeScript / Deno):**
An open-source alternative built on top of Deno and Dagger that enforces using **TypeScript** directly for pipeline declarations. It abstracts container steps into type-safe, importable TypeScript modules.

---

### Feature & IDE Comparison

| Tool | Primary Language / DSL | IDE Features (Autocompletion, Types, Refactoring) | Ecosystem / Execution |
| --- | --- | --- | --- |
| **Dagger** | Go, Python, TypeScript, Elixir | **Native** (uses standard language SDKs) | Runs in Docker locally or inside any runner |
| **TeamCity** | Kotlin DSL | **Best-in-class** (IntelliJ IDEA integration) | Agnostic, runs via TeamCity agents |
| **Jenkins** | Groovy DSL | **Good** (requires Jenkins Groovy plugin) | Agnostic, runs on self-hosted Jenkins nodes |
| **Fluent CI** | TypeScript | **Native** (VS Code / Deno Language Server) | Local CLI, provider-agnostic |

-----------------------------------------------------------------------------------------------------

````
I'm more interested in an example comparing a Dagger TypeScript pipeline with a Jenkins Groovy DSL.
````

-----------------------------------------------------------------------------------------------------

To illustrate the difference, here is how a build, test, and container packaging workflow is implemented in **Dagger (TypeScript)** versus **Jenkins (Groovy Pipeline DSL)**.

---

### Scenario

1. Pull source code.
2. Install Node.js dependencies and run `npm test`.
3. Build a production Docker image.

---

### Option 1: Dagger TypeScript SDK

Dagger runs container operations via a strongly-typed TypeScript API. It executes in a local engine or any remote runner without relying on server-specific plugins.

```typescript
import { connect, Client } from "@dagger.io/dagger";

// Dagger code runs as a standard Node/TypeScript application
connect(async (client: Client) => {
  // 1. Get reference to the local directory
  const source = client.host().directory(".", { exclude: ["node_modules", "dist"] });

  // 2. Define the Test container environment
  const nodeBase = client
    .container()
    .from("node:20-alpine")
    .withDirectory("/app", source)
    .withWorkdir("/app")
    .withExec(["npm", "ci"]);

  // Run tests (throws an explicit TypeScript exception on non-zero exit code)
  await nodeBase.withExec(["npm", "test"]).sync();

  // 3. Build a production container image using multi-stage operations
  const productionImage = client
    .container()
    .from("nginx:alpine")
    .withDirectory("/usr/share/nginx/html", nodeBase.withExec(["npm", "run", "build"]).directory("/app/dist"));

  // Publish to registry or export as image
  const address = await productionImage.publish("my-registry.com/my-app:latest");
  console.log(`Published image to ${address}`);
}, { LogOutput: process.stdout });

```

---

### Option 2: Jenkins Groovy Pipeline DSL

Jenkins uses a domain-specific Groovy DSL evaluated inside the Jenkins master server. It relies on Jenkins-specific syntax blocks (`pipeline`, `agent`, `stage`, `steps`) and server capabilities.

```groovy
pipeline {
    agent {
        docker {
            image 'node:20-alpine'
            args '-v /var/run/docker.sock:/var/run/docker.sock' // Requires socket access for docker builds
        }
    }
    
    stages {
        stage('Install & Test') {
            steps {
                sh 'npm ci'
                sh 'npm test'
            }
        }
        
        stage('Build & Package') {
            steps {
                sh 'npm run build'
                // Reconciling host/container commands via Jenkins sh step
                script {
                    docker.build("my-registry.com/my-app:latest", "-f Dockerfile .")
                }
            }
        }

        stage('Publish') {
            steps {
                script {
                    docker.withRegistry('https://my-registry.com', 'registry-credentials-id') {
                        docker.image("my-registry.com/my-app:latest").push()
                    }
                }
            }
        }
    }
}

```

---

### Core Structural & Developer Experience Differences

| Feature | Dagger (TypeScript) | Jenkins (Groovy DSL) |
| --- | --- | --- |
| **Execution Environment** | Runs anywhere Node/Docker can run (your laptop, GitHub Actions, GitLab CI). | Runs strictly inside a Jenkins Server/Agent environment. |
| **IDE Autocompletion** | Full TypeScript support. Works out of the box in VS Code, WebStorm, etc., with real types, linting, and docs. | Partial. Groovy plugins exist, but custom Jenkins pipeline steps often lack inline type hints. |
| **Local Debugging** | Run `npx ts-node ci.ts` directly on your machine. Identical behavior locally and in CI. | Difficult. Testing requires pushing to Git or running a local Jenkins server instance. |
| **Hermeticity & Isolation** | Every step happens inside isolated, API-controlled containers. | Dependent on the underlying agent machine state unless strictly bound inside Docker agents. |
| **Ecosystem Access** | Full access to the NPM ecosystem (e.g., `axios`, `aws-sdk`, native unit testing frameworks). | Limited to Jenkins Plugins, Jenkins Shared Libraries, or standard Java/Groovy code. |

-----------------------------------------------------------------------------------------------------

````
Can you compare both solutions with a Rust app example?
````

-----------------------------------------------------------------------------------------------------

Here is a direct comparison building and testing a **Rust binary application** (with build-caching for target files) using **Dagger** versus **Jenkins Groovy Pipeline**.

---

### Scenario

1. Mount cargo cache directories (`/usr/local/cargo/registry` and `./target`) to accelerate compilation.
2. Run `cargo test` to execute test suites.
3. Run `cargo build --release` to compile the optimized Rust binary.
4. Copy the compiled binary into a minimal `debian:bookworm-slim` runtime image.

---

### Option 1: Dagger (using the Rust SDK)

With Dagger, you can write the CI/CD pipeline **in Rust itself** using the `dagger-sdk` crate. This guarantees strong type-safety, local reproducibility via `cargo run`, and native container caching primitives.

```rust
use dagger_sdk::connect;

#[tokio::main]
async fn main() -> eyre::Result<()> {
    // 1. Connect to the local or remote Dagger Engine
    connect(|client| async move {
        // Define directory exclusions to prevent sending unnecessary files
        let src = client
            .host()
            .directory_opts(".", dagger_sdk::HostDirectoryOptsBuilder::default()
                .exclude(vec!["target"])
                .build()?)
            .build();

        // 2. Define persistent Caches for Cargo registry and build target dir
        let cargo_cache = client.cache_volume("cargo-registry");
        let target_cache = client.cache_volume("cargo-target");

        // 3. Configure the Rust Builder Container Environment
        let builder = client
            .container()
            .from("rust:1.78-slim")
            .with_mounted_cache("/usr/local/cargo/registry", cargo_cache)
            .with_mounted_cache("/app/target", target_cache)
            .with_directory("/app", src)
            .with_workdir("/app");

        // 4. Run tests
        builder
            .with_exec(vec!["cargo", "test"])
            .stdout()
            .await?;

        // 5. Compile release binary
        let compiled_builder = builder
            .with_exec(vec!["cargo", "build", "--release"]);

        // 6. Extract binary and stage into a minimal production runtime image
        let binary = compiled_builder.file("/app/target/release/my_rust_app");

        let runtime_image = client
            .container()
            .from("debian:bookworm-slim")
            .with_file("/usr/local/bin/my_rust_app", binary)
            .with_entrypoint(vec!["/usr/local/bin/my_rust_app"]);

        // Publish to registry or save image
        let image_ref = runtime_image.publish("my-registry.com/my-rust-app:latest").await?;
        println!("Published Rust application to: {}", image_ref);

        Ok(())
    })
    .await?;

    Ok(())
}

```

---

### Option 2: Jenkins Groovy Pipeline DSL

Jenkins handles Rust by executing shell commands inside a container agent or utilizing host-level environment tools.

```groovy
pipeline {
    agent {
        docker {
            image 'rust:1.78-slim'
            // Mount host directories to preserve Cargo cache between builds
            args '-v /var/cache/cargo/registry:/usr/local/cargo/registry -v /var/run/docker.sock:/var/run/docker.sock'
        }
    }

    environment {
        CARGO_HOME = '/usr/local/cargo'
    }

    stages {
        stage('Test') {
            steps {
                sh 'cargo test'
            }
        }

        stage('Build Release') {
            steps {
                sh 'cargo build --release'
            }
        }

        stage('Package Runtime Image') {
            steps {
                script {
                    // Jenkins Docker plugin invoked via shell to build final runtime image
                    def customImage = docker.build(
                        "my-registry.com/my-rust-app:latest",
                        "-f Dockerfile ."
                    )
                    
                    docker.withRegistry('https://my-registry.com', 'registry-credentials-id') {
                        customImage.push()
                    }
                }
            }
        }
    }
    
    post {
        always {
            // Manual cleanup needed for Docker containers
            cleanWs()
        }
    }
}

```

---

### Critical Rust-Specific Differences

| Feature | Dagger (Rust SDK) | Jenkins (Groovy DSL) |
| --- | --- | --- |
| **Cargo Caching** | Programmatic `cache_volume()` managed automatically by Dagger's engine. Does not pollute host disk. | Relies on raw host volume binds (`-v /var/...`), which can cause file-permission conflicts (`root` vs Jenkins user). |
| **Local Run Behavior** | Run `cargo run --bin ci` locally on a dev machine. It behaves identically to the remote pipeline execution. | Cannot run natively on a local machine without installing a local Jenkins instance. |
| **Type Safety & Compiler** | Checked by `rustc`. Renamed API methods or invalid container arguments cause compile failures *before execution*. | Errors in Groovy scripts or missing shell tools fail midway through pipeline runtime. |
| **Multi-Stage Assembly** | Constructs multi-stage builds dynamically via code (extracting `binary` to a runtime image) without writing a separate Dockerfile. | Requires a static `Dockerfile` on disk or inline scripting commands to produce production runtime artifacts. |

-----------------------------------------------------------------------------------------------------

````
How are self written utility functions (written in TS / Groovy) handled? Is there full IDE augmentation for the input/output arguments including documentation?
````

-----------------------------------------------------------------------------------------------------

**Yes, both Dagger (TypeScript) and Jenkins (Groovy) fully support IDE auto-completion, hover documentation, and parameter signature augmentation for custom functions.**

However, they achieve this through completely different mechanisms: **Dagger uses standard compiler language features and code generation**, while **Jenkins relies on specialized IDE plugins and runtime DSL reflection**.

---

### 1. Dagger (TypeScript)

Dagger leverages native TypeScript capabilities. Custom utility functions are standard TypeScript functions or Dagger Modules.

#### How Input/Output & Docs are Handled

* **JSDoc Parsing:** Dagger parses standard JSDoc comments (`/** ... */`) attached to your classes, functions, and parameters.
* **Full Augmentation:** When you hover over a function or type, your IDE (VS Code, WebStorm, etc.) surfaces parameter types, return types, and markdown documentation natively.
* **Dagger Engine CLI Auto-Docs:** If you package your utility functions into a **Dagger Module**, Dagger automatically reads your JSDoc comments to generate CLI help menus (`dagger call --help`) and auto-generates GraphQL schema documentation.

#### TypeScript Example

```typescript
/**
 * Configuration options for building a NodeJS service.
 */
export interface NodeBuildConfig {
  /** Path to the source code directory */
  sourceDir: Directory;
  /** Environment variables to pass into the container */
  envVars?: Record<string, string>;
}

/**
 * Builds a Node.js project inside a container and produces an optimized build directory.
 * 
 * @param client - The active Dagger client
 * @param config - The build configuration parameters
 * @returns A Directory object containing the compiled dist/ output
 */
export async function buildNodeApp(
  client: Client, 
  config: NodeBuildConfig
): Promise<Directory> {
  let container = client
    .container()
    .from("node:20-alpine")
    .withDirectory("/app", config.sourceDir)
    .withWorkdir("/app")
    .withExec(["npm", "ci"]);

  return container.withExec(["npm", "run", "build"]).directory("/app/dist");
}

```

* **Developer Experience in IDE:** Hovering over `buildNodeApp()` immediately pops up the rendered Markdown description, exact types for `config.sourceDir`, and type checks missing required fields before you run the code.

---

### 2. Jenkins (Groovy Pipelines)

Jenkins pipeline logic uses **Jenkins Shared Libraries** (`vars/` or `src/` directories) for reusable Groovy helper functions.

#### How Input/Output & Docs are Handled

* **Dynamic Typing vs. Type Hinting:** Groovy supports optional typing (`def` vs explicit types like `String`, `Map`). Using explicit Groovy types enables autocomplete, whereas using `def` causes the IDE to treat parameters as dynamic `Object` types.
* **GroovyDoc Parsing:** Standard `/** ... */` GroovyDoc comments are extracted by IDEs (IntelliJ IDEA, Eclipse) to provide hover documentation.
* **Jenkins Pipeline GDSL Generation:** To make custom pipeline steps visible to the IDE, Jenkins offers a `.gdsl` script (Groovy DSL Descriptor). This file tells your IDE what methods exist inside `vars/` and injects them into the global pipeline scope.

#### Groovy Example (`vars/buildNodeApp.groovy`)

```groovy
/**
 * Utility function to build a Node.js application inside a Docker container.
 * 
 * @param config Map containing configuration options:
 *   - nodeVersion (String): Node image tag (default: '20-alpine')
 *   - buildScript (String): NPM script to run (default: 'build')
 * @return Map containing build output metadata
 */
Map call(Map config = [:]) {
    String nodeVersion = config.get('nodeVersion', '20-alpine')
    String buildScript = config.get('buildScript', 'build')

    docker.image("node:${nodeVersion}").inside {
        sh 'npm ci'
        sh "npm run ${buildScript}"
    }

    return [status: 'SUCCESS', artifactPath: 'dist/']
}

```

#### The Catch with Jenkins Shared Libraries

While Dagger works instantly via standard `tsconfig.json`, Jenkins IDE augmentation requires extra setup:

1. **Map-based Args:** Jenkins functions commonly take a single `Map config` argument. The IDE knows `config` is a `Map`, but it **cannot auto-complete keys inside the Map** (e.g., `config.nodeVersion`) unless you explicitly define a Java/Groovy class for parameter options.
2. **IDE Plugin Requirement:** IntelliJ IDEA requires the **Jenkins Pipeline Linter Connector** or **Groovy Plugin** to resolve globally available pipeline steps (like `sh`, `docker`, `stage`).

---

### Quick Comparison Matrix

| Feature | Dagger (TypeScript) | Jenkins (Groovy) |
| --- | --- | --- |
| **Type Augmentation** | **Native & Strict.** TypeScript engine verifies inputs/outputs automatically. | **Optional / Partial.** Dynamic (`def`) by default; requires explicit Groovy/Java classes for strict checking. |
| **Hover Documentation** | Uses standard JSDoc. Supported by 100% of modern editors. | Uses GroovyDoc. Works in IntelliJ; patchy in VS Code. |
| **Map Property Autocomplete** | **Yes.** TypeScript Interfaces autocomplete nested map/object keys. | **No (by default).** Standard Groovy Maps (`Map config`) do not expose expected key names to IDEs. |
| **IDE Setup Friction** | Zero setup. Standard `npm` / `tsconfig` rules apply. | Medium setup. Requires configuring local Jenkins GDSL files or IntelliJ pipeline framework dependencies. |

-----------------------------------------------------------------------------------------------------

````
Reagarding the Rust example above for Dagger: Alternatively, the pipeline could also have been written in TypeScript, right? 
````

-----------------------------------------------------------------------------------------------------

**Yes, absolutely.** You can write a pipeline for a Rust application in TypeScript, Go, Python, or even as a Dagger Module.

In Dagger, **the language you write your pipeline in is decoupled from the language of the application you are building.**

When you write a pipeline in TypeScript, Dagger sends instructions via a GraphQL protocol to the underlying Dagger Engine (which runs as a Docker container). The engine executes the actual Rust build environment inside containers, regardless of the language driving it.

---

### Equivalent Rust Build Pipeline in Dagger (TypeScript)

Here is how the exact same Rust compilation, caching, and runtime packaging workflow looks when written in TypeScript:

```typescript
import { connect, Client } from "@dagger.io/dagger";

connect(async (client: Client) => {
  // 1. Get host directory excluding the local /target folder
  const src = client.host().directory(".", { exclude: ["target"] });

  // 2. Define persistent cache volumes for Cargo
  const cargoCache = client.cacheVolume("cargo-registry");
  const targetCache = client.cacheVolume("cargo-target");

  // 3. Configure the Rust Builder container environment
  const builder = client
    .container()
    .from("rust:1.78-slim")
    .withMountedCache("/usr/local/cargo/registry", cargoCache)
    .withMountedCache("/app/target", targetCache)
    .withDirectory("/app", src)
    .withWorkdir("/app");

  // 4. Run tests
  await builder.withExec(["cargo", "test"]).sync();

  // 5. Compile release binary
  const compiledBuilder = builder.withExec(["cargo", "build", "--release"]);

  // 6. Extract the compiled binary and stage it into a minimal runtime image
  const binary = compiledBuilder.file("/app/target/release/my_rust_app");

  const runtimeImage = client
    .container()
    .from("debian:bookworm-slim")
    .withFile("/usr/local/bin/my_rust_app", binary)
    .withEntrypoint(["/usr/local/bin/my_rust_app"]);

  // Publish or export the image
  const imageRef = await runtimeImage.publish("my-registry.com/my-rust-app:latest");
  console.log(`Published Rust application to: ${imageRef}`);
}, { LogOutput: process.stdout });

```

---

### Key Takeaway

* **Use Rust for the pipeline** if your team primarily consists of Rust developers and you want your pipeline code to sit alongside the app in the same codebase using tools they already know (`cargo run`).
* **Use TypeScript for the pipeline** if your team prefers JavaScript/TypeScript tooling, or wants to write shared CI/CD scripts using Node.js packages across heterogeneous repositories (e.g., frontend React apps, Python APIs, and Rust services).

-----------------------------------------------------------------------------------------------------

````

````

-----------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------

````

````

-----------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------

````

````

-----------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------

````

````

-----------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------

````

````

-----------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------


