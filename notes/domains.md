# Abstract Domains

The abstract domains for strictness analysis are specified below along with the basic data types and interfaces for some fundamental functions.

## Observations

1. Promises don't have an environment of their own. They either share the environment of the caller or the callee.
2. All promises corresponding to the arguments of the same function share the same graph. This is the graph of the callee.
3. So, we have a unique environment and graph for each function. Promises don't require their own environments or graphs.
4. The same environment can be paired with multiple graphs and the same graph can be paired with multiple environments. To make this work properly, we need a level of indirection for pairing environments and graphs.
5. A promise can be evaluated only once. Multiple evaluations can make the analysis imprecise. Hence, we need to store information about the state of promise evaluation. This makes the analysis more precise.
6. To update the graph, we need to know if the code being evaluated is that of function or promise. If a promise is being evaluated, we need to update that fact in the graph of the corresponding function but if a function is being evaluated, we don't have to update that fact in any graph. So, we need a mapping to distinguish between promise and function labels. 
7. The analysis is really expected to compute whether a function is strict in a particular argument position or not. So, we need to map each promise to its argument position.

## Overview

### Basic Types

`ℕ` denotes the set of natural numbers.

`ℙ(x)` denotes a set of values of type x (ordering does not matter).

`𝕊(x)` denotes a sequence of values of type x (ordering matters).

### Syntactic Categories

<code>Var</code>
<code>L</code>
<code>L<sub>P</sub></code>
<code>L<sub>F</sub></code>
<code>L<sub>⊥</sub></code>
<code>Code</code>
<code>Id<sub>E</sub></code>
<code>Id<sub>G</sub></code>

### Data Types

#### Forced

```
Forced ≝ Sometimes
            |
            |
            |
          Always
            |
            |
            |
          Never
```

#### Graph

##### Definition
```Graph ≝ ℙ(𝕊(ℕ))```

##### Interface

```
clone     :: Graph -> Graph
force     :: Graph -> ℕ -> Graph
merge     :: Graph -> Graph -> Graph
forced    :: Graph -> ℕ -> Forced
first     :: Graph -> ℙ(ℕ)
next      :: Graph -> ℕ -> ℙ(ℕ)
always    :: Graph -> ℙ(ℕ)
never     :: Graph -> ℙ(ℕ)
sometimes :: Graph -> ℙ(ℕ)
```

#### Environment

##### Definition

<code>Environment ≝ [Var ↦ ℙ(L<sub>P</sub> ∪ L<sub>F</sub> ∪ L<sub>⊥</sub>)]</code>

##### Interface

```
clone  :: Environment -> Environment
merge  :: Environment -> Environment -> Environment
add    :: Environment -> Var -> Lab -> Environment
remove :: Environment -> Var -> Environment
get    :: Environment -> Var -> ℙ(Lab)
```

### Maps

<code>M<sub>E</sub> ≝ [Id<sub>E</sub> ↦ Environment]</code>

<code>M<sub>G</sub> ≝ [Id<sub>G</sub> ↦ Graph]</code>

<code>M<sub>C</sub> ≝ [(L<sub>P</sub> ∪ L<sub>F</sub>) ↦ Code]</code>

<code>M<sub>P</sub> ≝ [L<sub>P</sub> ↦ ℕ]</code>

<code>M<sub>F</sub> ≝ [L<sub>P</sub> ↦ Forced]</code>

<code>M<sub>H</sub> ≝ [(L<sub>P</sub> ∪ L<sub>F</sub>) ↦ Id<sub>E</sub> × Id<sub>G</sub>]</code>

<code>S<sub>A</sub> ≝ (M<sub>E</sub>, M<sub>G</sub>, M<sub>F</sub>)</code>


## Description

### Var

`Var` is the set of variables used in the program. Variables point to functions or promises or values we don't care about.

<h3>L<sub>P</sub></h3>

<code>L<sub>P</sub></code> denotes the set of labels for uniquely labeling promises.

<h3>L<sub>F</sub></h3>

<code>L<sub>F</sub></code> denotes the set of labels for uniquely labeling functions.

<h3>L<sub>⊥</sub></h3>

<code>L<sub>⊥</sub></code> is a singleton set of labels for labeling non-function or non-promise values such as numbers, strings, matrices, lists, etc.

### Code

`Code` is the set of expressions or body of any function or promise.

<h3>Id<sub>G</sub></h3>

<code>Id<sub>G</sub></code> is the set of identifiers for uniquely identifying the `Graph`.

<h3>Id<sub>E</sub></h3>

<code>Id<sub>E</sub></code> is the set of identifiers for uniquely identifying the `Environment`.

### Forced

`Forced` is a lattice of three elements (`Always`, `Never` and `Sometimes`), corresponding to the strictness state of a particular argument position.

### Environment Map 

<code>M<sub>E</sub> ::= [Id<sub>E</sub> ↦ Environment]</code>

Maps each <code>Id<sub>E</sub></code> to a unique `Environment`. <code>Id<sub>E</sub></code> adds a layer of indirection needed to pair up the same `Graph` with different `Environment`.

### Graph Map

<code>M<sub>G</sub> ::= [Id<sub>G</sub> ↦ Graph]</code>

Maps each <code>Id<sub>G</sub></code> to a unique `Graph`. <code>Id<sub>G</sub></code> adds a layer of indirection needed to pair up the same `Environment` with different `Graph`.

### Code Map

<code>M<sub>C</sub> ≝ [(L<sub>P</sub> ∪ L<sub>F</sub>) ↦ Code]</code>

Maps each <code>L<sub>C</sub></code> to the `Code` of the entity (function or promise) that it labels.

### Position Map

<code>M<sub>P</sub> ≝ [L<sub>P</sub> ↦ ℕ]</code>

Maps each L<sub>P</sub> which labels a `Promise` to its argument position in the corresponding `Function`.

### Forced Map

<code>M<sub>F</sub> ≝ [L<sub>P</sub> ↦ Forced]</code>

Maps each L<sub>P</sub> which labels a `Promise` to its forced state, `Always`, `Never` or `Sometimes`. An abstract interpreter can use this to avoid re-evaluating a `Promise`, thus increasing precision.

### Heap Map

<code>M<sub>H</sub> ≝ [(L<sub>P</sub> ∪ L<sub>F</sub>) ↦ Id<sub>E</sub> × Id<sub>G</sub>]</code>

Maps each label of a function or a promise to the identifiers of its `Environment` and `Graph`.

### Abstract State

<code>S<sub>A</sub> ≝ (M<sub>E</sub>, M<sub>G</sub>, M<sub>F</sub>)</code>

This is the abstract state of the analysis. This contains <code>M<sub>E</sub></code>, <code>M<sub>G</sub></code> and <code>M<sub>F</sub></code>. At any point in the analysis, a function or promise can either force evaluation of another function or promise or use super assignment, thus modifying environments other than its own. So at any point in the program, the <code>S<sub>A</sub></code> is specified by all the `Environment` and `Graph` and state of other `Promise`. Whenever there is a fork in the control flow (`if` statements), we need to flow separate copies of `AS` along both paths and merge them at the join point. 
There is an advantage to formulating <code>S<sub>A</sub></code> as collection of per-function `Graph` and `Environment`. Cloning can be done lazily and an `Environment` or `Graph` will be actually copied only when it is modified. This makes merging almost constant time even though merging the <code>S<sub>A</sub></code> seemingly requires merging all the `Environment` and `Graph`.

### Graph

#### Definition
```Graph ::= ℙ(𝕊(ℕ))```

A `Graph` contains a sequence of argument positions for each control flow path across a function. The order of positions in the sequence is the order in which the arguments in those positions were forced along that control flow path.

Each `Function` has `Graph` associated with it. Thus, there are as many graphs as the number of `Function`. However, all `Promise` of a function call share the `Graph` of the callee.

#### Interface

The description below specifies the interface of the `Graph`.

#### clone

`clone     :: Graph -> Graph`

Clones a graph.

#### force

`force     :: Graph -> ℕ -> Graph`

Forces the argument at the given position and returns a new graph.

#### merge

`merge     :: Graph -> Graph -> Graph`

Merges two graphs and returns the new graph.

#### forced

`forced     :: Graph -> ℕ -> Forced`

Returns the forced state of the argument at the given position.

#### first

`first     :: Graph -> ℙ(ℕ)`

Returns the set of positions corresponding to arguments which were forced first.

#### next

`next      :: Graph -> ℕ -> ℙ(ℕ)`

Returns the set of positions corresponding to arguments which are forced after the given argument position.

#### always

`always    :: Graph -> ℙ(ℕ)`

Returns the set of positions corresponding to arguments which are always evaluated.

#### never

`never     :: Graph -> ℙ(ℕ)`

Returns the set of positions corresponding to arguments which are never evaluated.

#### sometimes

`sometimes :: Graph -> ℙ(ℕ)`

Returns the set of positions corresponding to arguments which are sometimes evaluated.

### Environment

#### Definition

<code>Environment ≝ [Var ↦ ℙ(L<sub>P</sub> ∪ L<sub>F</sub> ∪ L<sub>⊥</sub>)]</code>

An `Environment` maps each `Var` to <code>L<sub>P</sub> ∪ L<sub>F</sub> ∪ L<sub>⊥</sub></code>, i.e., to labels of entities the variable could point to at runtime. All non-function and non-promise values have the same label as we don't need to distinguish between them.
Each `Function` has an `Environment` associated with it. Thus, there are as many environments as the number of `Function`. However, `Promise` share the environment of the caller or the callee.

#### Interface

#### clone

`clone  :: Environment -> Environment`

Clones an environment.

#### merge

`merge  :: Environment -> Environment -> Environment`

Merges two environment and returns the new environment.

#### add

`add    :: Environment -> Var -> Lab -> Environment`

Adds the given label to the set of bindings of the given variable in the given environment and returns the new environment.

#### remove

`remove :: Environment -> Var -> Environment`

Removes the variable from the environment.

#### get
`get    :: Environment -> Var -> ℙ(Lab)`

Retrieves all the bindings for the given variable from the environment.
