# Conquer

Execute external commands from Swift with a simple, type-safe API.

## Overview

Conquer provides a small set of focused types to define shell commands, run them via pluggable executors, and consume output either as a stream or as a collected result. It aims to be predictable, testable, and safe by default.

- Define commands with ``Command`` and optional ``Environment``.
- Execute using the ``Executor`` protocol and the built-in ``SystemExecutor`` implementation.
- Choose between streaming output via ``Executor/stream(_:options:)`` and getting a collected ``ExecutionResult`` via ``Executor/run(_:options:)``.
- Configure behavior using ``ExecutionOptions`` and handle failures with ``ExecutionError``.

## Topics

### Command Definition

- ``Command``
- ``Environment``

### Executing Commands

- ``Executor``
- ``SystemExecutor``
- ``ExecutionOptions``
- ``ExecutionError``

### Output and Results

- ``CommandOutput``
- ``ExecutionResult``

### Convenience Commands

- ``Command/env(utility:arguments:currentDirectory:environment:)``
- ``Command/echo(_:omitTrailingNewline:)``
