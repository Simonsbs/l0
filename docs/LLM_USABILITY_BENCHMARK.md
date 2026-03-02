# LLM Usability and Token-Efficiency Benchmark

I use this benchmark to measure L0 usability for LLM workflows and track token-efficiency trends.

## Metrics I Track

- verify success rate (`l0c verify` pass rate)
- semantic success rate (build+run output matches expected)
- average turns to pass
- prompt/output token proxies
- L0 vs C token ratio
- tokens per verified/semantic program

## Deterministic Corpus

I use:
- `tests/llm_bench/tasks.tsv`
- prompt files in `tests/llm_bench/prompts/`
- expected canonical L0 outputs from `docs/examples/`
- baseline C snippets in `tests/llm_bench/baseline_c/`

## Runner

```sh
bash tests/llm_usability_bench.sh ./bin/l0c .
```

Default mode is `reference` (upper-bound control run using known-good outputs).

I can also run adapter mode:

```sh
L0_LLM_ADAPTER_CMD='<your command>' \
bash tests/llm_usability_bench.sh ./bin/l0c . cmd
```

The adapter command must read prompt text from stdin and output L0 source on stdout.

## Output Artifacts

- `docs/LLM_BENCHMARK_RESULTS.json`
- `docs/LLM_BENCHMARK_RESULTS.md`

I publish these docs to the wiki through the existing docs->wiki sync pipeline.
