# glamsterdam-devnet-6 Assertoor Playbooks

Branch: [`qu0b/assertoor/glamsterdam-devnet-6-eels`](https://github.com/qu0b/assertoor/tree/qu0b/assertoor/glamsterdam-devnet-6-eels)

These assertoor playbooks live-test EIP implementations on glamsterdam-devnet-6 (Amsterdam fork).
They deploy contracts, send transactions, and verify on-chain state against EIP specs.

---

## Playbook Index

| Filename | ID | Name | EIP(s) | Notes |
|----------|----|------|--------|-------|
| `glamsterdam-devnet-6-eels-tests.yaml` | `glamsterdam-devnet-6-eels-tests` | Run EELS execution spec tests | 2780, 7708, 7778, 7843, 7928, 7954, 7976, 7981, 7997, 8024, 8037, 8246, 8282 | Comprehensive EELS spec suite; requires genesis-generator >= 6.1.0 |
| `glamsterdam-devnet-6-eip7708-transfer-logs.yaml` | `glamsterdam-devnet-6-eip7708-transfer-logs` | ETH transfer log emission | EIP-7708 | Checks `Transfer(address,address,uint256)` logs from `0xfff...ffe` |
| `glamsterdam-devnet-6-eip7843-slotnum.yaml` | `glamsterdam-devnet-6-eip7843-slotnum` | SLOTNUM opcode (0x49) verification | EIP-7843 | Deploys via EIP-7997 Arachnid factory; checks opcode value >= 64 at epoch 2 |
| `glamsterdam-devnet-6-eip7954-initcode.yaml` | `glamsterdam-devnet-6-eip7954-initcode` | 128 KiB initcode / 64 KiB code size limit | EIP-7954 | Deploys 30 KiB (> old 24576 Prague limit) and 60 KiB contracts; requires foundry |
| `glamsterdam-devnet-6-eip7997-factory.yaml` | `glamsterdam-devnet-6-eip7997-factory` | Arachnid CREATE2 factory pre-deploy | EIP-7997 | Verifies factory at `0x4e59b44847b379578588920ca78fbf26c0b4956c`; no foundry needed |
| `glamsterdam-devnet-6-eip8037-refund-routing.yaml` | `glamsterdam-devnet-6-eip8037-refund-routing` | Source-based gas refund routing | EIP-8037 | Measures sender balance delta to confirm refund credited to tx.origin; requires foundry |
| `glamsterdam-devnet-6-eip8038-gas-verify.yaml` | `glamsterdam-devnet-6-eip8038-gas-verify` | SSTORE gas repricing verification | EIP-8038 | Tests COLD_STORAGE_WRITE=5000; also checks EIP-2780 TX_BASE; requires foundry |
| `glamsterdam-devnet-6-eip8246-no-burn.yaml` | `glamsterdam-devnet-6-eip8246-no-burn` | SELFDESTRUCT no-burn | EIP-8246 | Verifies ETH sent to address(0) via SELFDESTRUCT is dropped, not credited; requires foundry |
| `glamsterdam-devnet-6-eip8024-opcodes.yaml` | `glamsterdam-devnet-6-eip8024-opcodes` | EIP-8024 SWAPN/DUPN/EXCHANGE opcode suite (EELS + live smoke) | EIP-8024 | Runs full EELS test_swapn/test_dupn/test_exchange suites from tag v6.0.0; plus eth_call smoke tests |
| `glamsterdam-devnet-6-eip7981-access-list-gas.yaml` | `glamsterdam-devnet-6-eip7981-access-list-gas` | Access list storage key cost 2400→1900 | EIP-7981 | Uses eth_estimateGas with 100 keys; on-chain type-1 tx with 50 keys to confirm 1900/key |
| `glamsterdam-devnet-6-eip2780-intrinsic-gas.yaml` | `glamsterdam-devnet-6-eip2780-intrinsic-gas` | TX_BASE=21000 and calldata repricing | EIP-2780 | Simple transfer gasUsed==21000; zero/nonzero byte cost 4/16; calldata delta verification |
| `glamsterdam-devnet-6-eip7976-calldata-floor.yaml` | `glamsterdam-devnet-6-eip7976-calldata-floor` | Calldata floor cost (64 gas/byte) | EIP-7976 | Verifies floor = 21000+64×len(calldata) via eth_estimateGas; both zero and nonzero bytes hit same floor |
| `glamsterdam-devnet-6-builder-lifecycle.yaml` | `glamsterdam-devnet-6-builder-lifecycle` | EIP-8282 builder deposit and exit lifecycle | EIP-8282 | Tests builder deposit/exit predeploys; waits for GLOAS fork epoch; requires foundry |
| `bal-devnet-3-eels-tests.yaml` | `bal-devnet-3-eels-tests` | EELS spec tests for bal-devnet-3 | bal-devnet-3 EIPs | Legacy; pinned to `devnets/bal/3` branch |
| `bal-devnet-4-eels-tests.yaml` | `bal-devnet-4-eels-tests` | EELS spec tests for bal-devnet-4 | bal-devnet-4 EIPs | Legacy; pinned to `tests-snøbal-devnet-4@v1.0.0` |
| `bal-devnet-4-eip8024-stack235-only.yaml` | `bal-devnet-4-eip8024-stack235-only` | EIP-8024 swapn_stack_235 repro (debug) | EIP-8024 | Debug repro for EEST PR #2760; uses `qu0b/execution-specs` fork |
| `bal-devnet-5-eels-tests.yaml` | `bal-devnet-5-eels-tests` | EELS spec tests for bal-devnet-5 | bal-devnet-5 EIPs | Legacy; pinned to `tests-snobal-devnet-5@v8037.0.0` |
| `execution-sec-tests-sequential.yaml` | `glamsterdam-execution-spec-tests-sequential-glamsterdam` | Run execution spec tests sequentially | all | Debug helper; runs tests one at a time |

---

## Dependencies

### genesis-generator >= 6.1.0

Required for `glamsterdam-devnet-6-eels-tests.yaml` and `glamsterdam-devnet-6-builder-lifecycle.yaml`.
EIP-8282 needs the builder registry predeploy (`0x0000884d2AA32eAa155F59A2f24eFa73D9008282`) in genesis,
which genesis-generator added in 6.1.0. If running on an older generator, skip the builder tests or
run them only after verifying the predeploy exists.

### Foundry (forge + cast)

All playbooks that deploy or interact with contracts install foundry at runtime via `foundryup`.
There is no pre-installed foundry requirement; each test that needs it installs and cleans up its own copy.
An internet connection to `foundry.paradigm.xyz` is required during test execution.

Playbooks that install foundry: `eip7954-initcode`, `eip8037-refund-routing`, `eip8038-gas-verify`,
`eip8246-no-burn`, `builder-lifecycle`, `eip7981-access-list-gas`, `eip2780-intrinsic-gas`,
`eels-tests` (indirectly via foundry steps).

Playbooks that do NOT require foundry: `eip7997-factory`, `eip7843-slotnum` (uses raw eth_call via curl),
`eip7708-transfer-logs`, `eip8024-opcodes` (uses EELS for the suite; eth_call smoke test via curl).

---

## Running Playbooks: Independent vs. Together

### Run independently (self-contained)

Each glamsterdam-devnet-6 EIP playbook is fully self-contained: it generates its own funded wallets,
installs any tooling it needs, and cleans up after itself. They can be run in any order and in parallel.

| Playbook | Can run in parallel? |
|----------|---------------------|
| `eip7708-transfer-logs` | Yes |
| `eip7843-slotnum` | Yes (depends on EIP-7997 being live in genesis, not on the 7997 playbook) |
| `eip7954-initcode` | Yes |
| `eip7997-factory` | Yes |
| `eip8024-opcodes` | Yes |
| `eip7981-access-list-gas` | Yes |
| `eip2780-intrinsic-gas` | Yes |
| `eip7976-calldata-floor` | Yes |
| `eip8037-refund-routing` | Yes |
| `eip8038-gas-verify` | Yes |
| `eip8246-no-burn` | Yes |
| `builder-lifecycle` | Yes, but waits for GLOAS fork epoch |

### Run sequentially (ordering recommendation)

If running the full suite manually, a natural order is:

1. `eip7997-factory` — verifies the CREATE2 factory predeploy (other tests may use it)
2. `eip7843-slotnum` — uses the factory internally
3. `eip7708-transfer-logs`, `eip7954-initcode`, `eip8037-refund-routing`, `eip8038-gas-verify`, `eip8246-no-burn`, `eip8024-opcodes`, `eip7981-access-list-gas`, `eip2780-intrinsic-gas`, `eip7976-calldata-floor` — in any order
4. `builder-lifecycle` — last, since it waits for GLOAS epoch
5. `glamsterdam-devnet-6-eels-tests` — runs the full EELS suite; takes up to 6 hours; run last or standalone

### Legacy devnet playbooks

`bal-devnet-3-eels-tests`, `bal-devnet-4-eels-tests`, `bal-devnet-4-eip8024-stack235-only`,
and `bal-devnet-5-eels-tests` are for previous devnets and should not be run on glamsterdam-devnet-6
(different fork config, different EIP set, pinned to incompatible spec branches).

---

## EIP Reference

| EIP | Title | Amsterdam change |
|-----|-------|-----------------|
| EIP-2780 | Reduce intrinsic transaction gas | TX_BASE=21000 unchanged; calldata token model (zero=4, nonzero=16 gas/byte) |
| EIP-7708 | ETH transfer logs | `Transfer(from, to, value)` emitted by `0xfff...ffe` on every ETH move |
| EIP-7843 | SLOTNUM opcode | New opcode `0x49` pushes current beacon slot number |
| EIP-7954 | Increase maximum contract sizes | MAX_CODE_SIZE 24576 → 65536; MAX_INIT_CODE_SIZE 49152 → 131072 |
| EIP-7997 | Arachnid CREATE2 factory pre-deploy | Factory at `0x4e59b44847b379578588920ca78fbf26c0b4956c` in genesis |
| EIP-8037 | Source-based gas refund routing | State-clearing refunds credited to tx.origin, not coinbase |
| EIP-8038 | SSTORE gas repricing | COLD_STORAGE_WRITE = 5000 (was 22100); COLD_STORAGE_ACCESS unchanged at 2100 |
| EIP-8246 | SELFDESTRUCT no-burn | ETH sent to address(0) via SELFDESTRUCT is dropped (not credited to address(0)) |
| EIP-7981 | Reduce access list storage key cost | ACCESS_LIST_STORAGE_KEY_COST: 2400 → 1900 (address cost unchanged) |
| EIP-8024 | SWAPN/DUPN/EXCHANGE opcodes | Three new EVM opcodes for stack manipulation; work in legacy bytecode |
| EIP-7976 | Increase calldata floor cost | floor_data_cost = 21000 + 64 × len(calldata); actual = max(standard, floor) |
| EIP-8282 | Builder execution requests | Builder deposit/exit predeploys; requires genesis-generator >= 6.1.0 |
