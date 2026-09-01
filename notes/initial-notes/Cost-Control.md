# Cost Control


-----------------------------------------------------------------------------------------------------

````
using spec driven development and aiming to guard the cost for the development of specific features: Which indicators and control mechanisms are commonly used to manage cost of cloud LLM usage?
````

-----------------------------------------------------------------------------------------------------

In Specification-Driven Development (SDD), you define exact system behavior before writing code. When applied to cloud Large Language Models (LLMs), this allows you to set precise financial boundaries for every feature. [1] 
The following key indicators and control mechanisms are commonly used to manage and guard cloud LLM costs:

## Key Cost Indicators (Metrics)

* Token Consumption: Track total input and output tokens per feature execution.
* Cost per Request: Calculate the exact financial cost of a single API call.
* Latency-to-Cost Ratio: Monitor if higher cost models actually deliver faster, required performance.
* Cache Hit Rate: Measure the percentage of prompts served from cheaper context caches.
* Token Efficiency: Track the ratio of useful output tokens to wasted system/prompt tokens.

## Control Mechanisms (Guardrails)

* Prompt Budgets: Enforce strict token limits in code for every prompt and response.
* Semantic Caching: Store and reuse answers for similar user queries to skip LLM calls.
* Model Routing: Route simple tasks to cheap models and complex tasks to premium models.
* Rate & Cost Throttling: Implement API gateways to block users or features exceeding budget limits.
* Automated Regression Testing: Run SDD test suites to ensure prompt updates do not increase token costs.

Would you like to explore code examples for implementing model routing, or see how to write SDD test cases that assert maximum token limits for a specific feature?

-----------------------------------------------------------------------------------------------------

````
Please create some example config files for open spec.
````

-----------------------------------------------------------------------------------------------------

To guard cloud LLM costs within Specification-Driven Development (SDD), you can use open specifications like OpenAPI 3.1 (for API gateways and routing) and Promptfile/Promptfoo formats (for testing prompts against cost assertions).
Here are three practical configuration examples designed to track, limit, and control LLM expenses.
## 1. OpenAPI 3.1: Enforcing Rate Limits and Token Headers
This specification defines a standard feature endpoint. It mandates cost-tracking headers in the response and enforces an API gateway policy for maximum token usage per request.

openapi: 3.1.0info:
  title: Feature LLM Gateway
  version: 1.0.0
  description: Spec-driven API enforcing cost controls per feature.paths:
  /v1/features/summarize:
    post:
      summary: Summarize text using a cost-bounded LLM
      operationId: summarizeText
      parameters:
        - name: X-Max-Tokens
          in: header
          required: true
          description: Strict budget limit for this feature call.
          schema:
            type: integer
            default: 1500
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                text:
                  type: string
      responses:
        '200':
          description: Successful summary with cost transparency data.
          headers:
            X-LLM-Cost-USD:
              schema:
                type: number
              description: Calculated financial cost of the request.
            X-Tokens-Used:
              schema:
                type: integer
              description: Total tokens consumed (Prompt + Completion).
          content:
            application/json:
              schema:
                type: object
                properties:
                  summary:
                    type: string
        '429':
          description: Token budget exceeded or rate limit hit.

## 2. Promptfoo Configuration: Cost-Driven Assertion Testing
[Promptfoo](https://www.promptfoo.dev/) is an open-source CLI tool to evaluate prompts. This configuration runs automated SDD tests to ensure changes to your prompt do not push the feature's operational cost above your financial guardrails.

# promptfooconfig.yamldescription: "SDD Cost Guardrails for Feature: Customer Support Router"
prompts:
  - "Categorize this ticket. Use max 10 words. Ticket: {{ticket_body}}"
providers:
  - id: openai:gpt-4o-mini
    config:
      temperature: 0.0
tests:
  - vars:
      ticket_body: "I need to cancel my subscription immediately, your app is broken."
    assert:
      # Cost-driven assertion: Fail test if model execution exceeds $0.002
      - type: cost
        value: 0.002
      # Size assertion: Prevent prompt injection from generating massive costly outputs
      - type: javascript
        value: output.split(' ').length <= 15

## 3. Model Routing Matrix: Custom Specification for Multi-LLM Tiering
This is a custom YAML configuration standard used by development teams in an SDD workflow to define exactly which model handles a task based on complexity and cost budget.

# llm-routing-spec.yamlversion: "1.0"feature_name: "AI Email Assistant"
cost_guardrails:
  max_monthly_budget_usd: 500.00
  default_fallback_model: "openai/gpt-4o-mini"
routing_rules:
  - rule_id: "simple_reply"
    condition: "intent == 'acknowledgment' or word_count < 50"
    target_model: "google/gemini-1.5-flash"
    max_tokens_budget: 400
    cache_enabled: true

  - rule_id: "complex_analysis"
    condition: "intent == 'escalation' or sentiment == 'angry'"
    target_model: "anthropic/claude-3-5-sonnet"
    max_tokens_budget: 4000
    cache_enabled: false

Would you like to see how to implement the Python middleware that reads the OpenAPI headers to enforce these token budgets, or do you want to write CI/CD pipeline steps to run the Promptfoo cost tests automatically?

-----------------------------------------------------------------------------------------------------

````
In an https://github.com/Fission-AI/openspec project I'd suppose to have some default guardrails for features which can be overridden by custom guardrails. Is this possible?
````

-----------------------------------------------------------------------------------------------------

Yes, absolutely. In OpenSpec, managing feature-specific overrides and cross-cutting concerns (like default cost guardrails) is handled through its core architecture of lightweight, file-based specs and its Customization layer.
Because OpenSpec organizes changes into dedicated folders (openspec/changes/<change-name>/specs/), you can model global defaults and local feature overrides directly using OpenSpec's markdown pattern.
Here is how you structure default guardrails and override them for specific features in an OpenSpec project:
## 1. Global Project-Wide Guardrails (The Defaults)
To establish universal cost and token baselines that every feature must respect, you define a global requirement spec in your root openspec/ directory.
Create openspec/specs/global_cost_guardrails.md:

## Global Cost & Token GuardrailsThe application SHALL enforce default system limits to protect cloud LLM budgets across all standard AI-driven features.
### Requirement: Default Max Output LengthBy default, all completion-based features must restrict responses to conserve output tokens.#### Scenario: Standard Feature Request- **WHEN** an AI feature generates an automated text response- **THEN** it SHALL limit output generation to a maximum of 500 tokens unless a feature override spec states otherwise
### Requirement: Default Target Model SelectionTo control API pricing, standard tasks must default to cost-effective reasoning tiers.#### Scenario: Standard Fallback Routing- **WHEN** executing a generic text processing task
- **THEN** the system SHALL route the request to `openai/gpt-4o-mini` or equivalent cost-tier model

------------------------------
## 2. Feature-Specific Overrides (The Changes)
When you use /opsx:propose <feature-name> to create a high-cost or high-complexity feature, OpenSpec creates a specific change directory. In this folder, you explicitly document the requirement that overrides the global default.
Inside your newly generated feature spec (openspec/changes/premium-email-analysis/specs/requirements.md):

## OVERRIDING Requirements: Premium Email Analysis### Requirement: Elevated Output BudgetThis feature parses dense financial emails and requires an increased ceiling above the project's standard 500-token default.#### Scenario: Analyzing large legal disclosures- **WHEN** compiling the executive email summary- **THEN** the app SHALL override the global token limit and permit up to 4,000 output tokens
### Requirement: High-Reasoning Model AllocationStandard cost-optimized routing (`gpt-4o-mini`) is insufficient for the semantic accuracy required here.#### Scenario: Complex multi-sender compliance check- **WHEN** evaluating compliance risks in the email body
- **THEN** the routing layer SHALL override the default model and explicitly target `anthropic/claude-3-5-sonnet`

------------------------------
## 3. Automating with Community Schemas
To make these guardrails actionable for your code and test suites, you can leverage OpenSpec's Community Schemas and customization hooks.
If your team uses an extension to parse specs into code configuration, OpenSpec allows you to bind a custom validator to your profile. You can have an automated task step (tasks.md) or a verify hook (/opsx:verify) look for the keyword override in active features:

   1. Fallback Logic: The underlying code looks at openspec/specs/global_cost_guardrails.md for a baseline.
   2. Override Discovery: When a feature is active in openspec/changes/, the application runtime merges or overwrites the active dictionary with the local feature spec constraints before hitting the LLM gateway.

Would you like to write a custom task checklist (tasks.md) template that ensures your coding agent implements the middleware code necessary to parse these spec overrides?

-----------------------------------------------------------------------------------------------------

````

````

-----------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------

````

````

-----------------------------------------------------------------------------------------------------


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

````

````

-----------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------
