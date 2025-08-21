# DeepSeek Models & Pricing Documentation

*Downloaded from: https://api-docs.deepseek.com/quick_start/pricing*
*Download date: 2025-08-21*

---

## Overview

The prices listed below are in units of per 1M tokens. A token, the smallest unit of text that the model recognizes, can be a word, a number, or even a punctuation mark. We will bill based on the total number of input and output tokens by the model.

## Model Details

| MODEL | deepseek-chat | deepseek-reasoner |
|-------|---------------|-------------------|
| **MODEL VERSION** | DeepSeek-V3.1 (Non-thinking Mode) | DeepSeek-V3.1 (Thinking Mode) |
| **CONTEXT LENGTH** | 128K | 128K |
| **MAX OUTPUT** | **DEFAULT**: 4K<br>**MAXIMUM**: 8K | **DEFAULT**: 32K<br>**MAXIMUM**: 64K |
| **FEATURES** | | |
| &nbsp;&nbsp;Json Output | ✓ | ✓ |
| &nbsp;&nbsp;Function Calling | ✓ | ✗(1) |
| &nbsp;&nbsp;Chat Prefix Completion（Beta） | ✓ | ✓ |
| &nbsp;&nbsp;FIM Completion（Beta） | ✓ | ✗ |

> **(1) Note**: If the request to the `deepseek-reasoner` model includes the `tools` parameter, the request will actually be processed using the `deepseek-chat` model.

## Pricing Details

### New Pricing (Effective September 5th, 2025 at 16:00 UTC)

Starting from 16:00 UTC Time on Sept 5th, 2025, we will apply the following price list and cancel the nighttime discount:

| MODEL | deepseek-chat | deepseek-reasoner |
|-------|---------------|-------------------|
| **1M INPUT TOKENS (CACHE HIT)** | $0.07 | $0.07 |
| **1M INPUT TOKENS (CACHE MISS)** | $0.56 | $0.56 |
| **1M OUTPUT TOKENS** | $1.68 | $1.68 |

### Current Pricing (Until September 5th, 2025 at 16:00 UTC)

The current price list will remain in effect until 16:00 UTC Time on Sept 5th, 2025:

| MODEL | deepseek-chat | deepseek-reasoner |
|-------|---------------|-------------------|
| **STANDARD PRICE**<br>（UTC 00:30-16:30） | | |
| &nbsp;&nbsp;1M INPUT TOKENS (CACHE HIT) | $0.07 | $0.14 |
| &nbsp;&nbsp;1M INPUT TOKENS (CACHE MISS) | $0.27 | $0.55 |
| &nbsp;&nbsp;1M OUTPUT TOKENS | $1.10 | $2.19 |
| **DISCOUNT PRICE**<br>（UTC 16:30-00:30） | | |
| &nbsp;&nbsp;1M INPUT TOKENS (CACHE HIT) | $0.035 | $0.035 |
| &nbsp;&nbsp;1M INPUT TOKENS (CACHE MISS) | $0.135 | $0.135 |
| &nbsp;&nbsp;1M OUTPUT TOKENS | $0.550 | $0.550 |

## Deduction Rules

The expense = number of tokens × price. The corresponding fees will be directly deducted from your topped-up balance or granted balance, with a preference for using the granted balance first when both balances are available.

Product prices may vary and DeepSeek reserves the right to adjust them. We recommend topping up based on your actual usage and regularly checking this page for the most recent pricing information.

---

## Key Information Summary

### Model Comparison

**deepseek-chat**:
- Non-thinking mode
- 8K max output
- Full feature support (Function Calling, FIM Completion)
- Lower pricing

**deepseek-reasoner**:
- Thinking mode
- 64K max output (8x more than chat)
- Limited feature support (no Function Calling, no FIM)
- Higher pricing (except after Sept 5th)

### Pricing Timeline

- **Until Sept 5th, 2025**: Discount pricing during UTC 16:30-00:30
- **After Sept 5th, 2025**: Unified pricing, no nighttime discount
- **Cache Hit**: Significantly cheaper than cache miss
- **Output Tokens**: Generally more expensive than input tokens

### Cost Optimization Tips

1. **Use Cache**: Cache hits are much cheaper (up to 8x savings)
2. **Time Usage**: Until Sept 5th, use during UTC 16:30-00:30 for discount
3. **Model Selection**: Use `deepseek-chat` for function calling needs
4. **Output Management**: Monitor output tokens as they cost more

### Token Estimation

- 1 token ≈ 4 characters in English
- 1 token ≈ 1-2 words in English
- 1000 tokens ≈ 750 words
- Cache hits can reduce costs by up to 87.5%

---

*This documentation was downloaded from DeepSeek API docs and saved locally for reference.*