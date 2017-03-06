# Abstract Domains

The abstract domains for strictness analysis are specified below along with the basic data types and interfaces for some fundamental functions.

## Observations

1. Promises don't have an environment of their own. They either share the environment of the caller or the callee.
2. All promises corresponding to the arguments of the same function share the same graph. This is the graph of the callee.
3. So, we have a new environment and graph for each function. Promises don't require new environments or graphs.
4. The same environment can be paired with multiple graphs and the same graph can be paired with multiple environments.
5. To make this work properly, we need a level of indirection for pairing environments and graphs.
6. A promise can be evaluated only once. Multiple evaluations can make the analysis imprecise. Hence, we need to store information about the state of promise evaluation.
7. To update the graph, we need to know if the code being evaluated is that of function or promise. If a promise is being evaluated, we need to update that fact in the graph of the corresponding function but if a function is being evaluated, we don't have to update that fact in any graph. So, we need a mapping to distinguish between promise and function labels. 
8. The analysis is really expected to compute whether a function is strict in a particular argument position or not. So, we need to map each promise to its argument position.

## Overview

### Syntactic Categories


<code>Var</code>
<code>Lab</code>
<code>Code</code>
<code>Id<sub>E</sub></code>
<code>Id<sub>G</sub></code>

### Data Types

#### Type

```
Type ::= Promise
       | Function
```

#### Forced

```
Forced ::= Always
         | Never
         | Sometimes 
```

#### Graph (Interface)

```Graph ::= [Natural ↦ ℙ(Natural)]```

```
clone     :: Graph -> Graph
force     :: Graph -> Natural -> Graph
merge     :: Graph -> Graph -> Graph
forced     :: Graph -> Natural -> Forced
first     :: Graph -> ℙ(Natural)
next      :: Graph -> Natural -> ℙ(Natural)
always    :: Graph -> ℙ(Natural)
never     :: Graph -> ℙ(Natural)
sometimes :: Graph -> ℙ(Natural)
```

#### Environment (Interface)

```Environment ::= [Var ↦ ℙ(Lab)]```

```
clone  :: Environment -> Environment
merge  :: Environment -> Environment -> Environment
add    :: Environment -> Var -> Lab -> Environment
remove :: Environment -> Var -> Environment
get    :: Environment -> Var -> ℙ(Lab)
```

### Maps

<code>M<sub>E</sub> ::= [Id<sub>E</sub> ↦ Environment]</code>

<code>M<sub>G</sub> ::= [Id<sub>G</sub> ↦ Graph]</code>

<code>M<sub>C</sub> ::= [Lab ↦ Code]</code>

<code>M<sub>T</sub> ::= [Lab ↦ Type]</code>

<code>M<sub>S</sub> ::= [Lab ↦ (Id<sub>E</sub>, Id<sub>G</sub>)]</code>

<code>M<sub>P</sub> ::= [Lab ↦ Natural]</code>

<code>M<sub>F</sub> ::= [Lab ↦ Forced]</code>

<code>AS ::= (M<sub>E</sub>, M<sub>G</sub>)</code>

## Description

### Var

`Var` is the set of variables used in the program. Variables point to functions or promises or values we don't care about.

### Lab

`Lab` is the set of labels. There is a unique label for each function and promise. 

### Code

`Code` is the set of expressions or body of any function or promise.

<h3>Id<sub>G</sub></h3>

<code>Id<sub>G</sub></code> is the set of identifiers for uniquely identifying the `Graph`.

<h3>Id<sub>E</sub></h3>

<code>Id<sub>E</sub></code> is the set of identifiers for uniquely identifying the `Environment`.

### Type

`Type` specifies the type of labeled entity, either a `Function` or a `Promise`.

### Forced

`Forced` specifies the strictness state of a particular argument position, one of `Always`, `Never` and `Sometimes`.

### Environment Map 

<code>M<sub>E</sub> ::= [Id<sub>E</sub> ↦ Environment]</code>

Maps each <code>Id<sub>E</sub></code> to a unique `Environment`. <code>Id<sub>E</sub></code> adds a layer of indirection needed to pair up the same `Graph` with different `Environment`.

### Graph Map

<code>M<sub>G</sub> ::= [Id<sub>G</sub> ↦ Graph]</code>

Maps each <code>Id<sub>G</sub></code> to a unique `Environment`. <code>Id<sub>G</sub></code> adds a layer of indirection needed to pair up the same `Environment` with different `Graph`.

### Code Map

<code>M<sub>C</sub> ::= [Lab ↦ Code]</code>

Maps each `Lab` to its unique `Code`.

### Type Map

<code>M<sub>T</sub> ::= [Lab ↦ Type]</code>

Maps each `Lab` to the type of syntactic entity it labels, a `Function` or a `Promise`.

### Position Map

<code>M<sub>P</sub> ::= [Lab ↦ Natural]</code>

Maps each `Lab` which labels a `Promise` to its argument position in the corresponding `Function`.

### Forced Map

<code>M<sub>F</sub> ::= [Lab ↦ Forced]</code>

Maps each `Lab` which labels a `Promise` to its forced state, `Always`, `Never` or `Sometimes`.

### Abstract State Map

<code>M<sub>S</sub> ::= [Lab ↦ (Id<sub>E</sub>, Id<sub>G</sub>)]</code>

Maps each `Lab` to the abstract state of the entity it labels, i.e., a tuple of <code>Id<sub>E</sub></code> and <code>Id<sub>G</sub></code>.

### Abstract State

<code>AS ::= (M<sub>E</sub>, M<sub>G</sub>)</code>

This is the abstract state of the analysis. This contains both <code>M<sub>E</sub></code> and <code>M<sub>G</sub></code>. At any point in the analysis, a function or promise can either force evaluation of another function or promise or use super assignment, thus modifying environments other than its own. So at any point in the program, the `AS` is specified by all the `Environment` and `Graph`. Whenever there is a fork in the control flow (`if` statements), we need to flow separate copies of `AS` along both paths and merge them at the join point. 
There is an advantage to formulating `AS` as collection of per-function `Graph` and `Environment`. Cloning can be done lazily and an `Environment` or `Graph` will be actually copied only when it is modified. This makes merging almost constant time even though merging the `AS` seemingly requires merging all the `Environment` and `Graph`.

### Graph (Interface)

```Graph ::= [Natural ↦ ℙ(Natural)]```

Each `Function` has `Graph` associated with it. Thus, there are as many graphs as the number of `Function`. However, all `Promise` of a function call share the Graph of the callee.
The description below specifies the interface of the `Graph`.

#### clone

`clone     :: Graph -> Graph`

Clones a graph.

#### force

`force     :: Graph -> Natural -> Graph`

Forces the argument at the given position and returns a new graph.

#### merge

`merge     :: Graph -> Graph -> Graph`

Merges two graphs and returns the new graph.

#### forced

`forced     :: Graph -> Natural -> Forced`

Returns the forced state of the argument at the given position.

#### first

`first     :: Graph -> P(Natural)`

Returns the set of positions corresponding to arguments which were forced first.

#### next

`next      :: Graph -> Natural -> P(Natural)`

Returns the set of positions corresponding to arguments which are forced after the given argument position.

#### always

`always    :: Graph -> P(Natural)`

Returns the set of positions corresponding to arguments which are always evaluated.

#### never

`never     :: Graph -> P(Natural)`

Returns the set of positions corresponding to arguments which are never evaluated.

#### sometimes

`sometimes :: Graph -> P(Natural)`

Returns the set of positions corresponding to arguments which are sometimes evaluated.

### Environment (Interface)

```Environment ::= [Var ↦ ℙ(Lab)]```

Each `Function` has an `Environment` associated with it. Thus, there are as many environments as the number of `Function`. However, `Promise` share the environment of the caller or the callee.

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
`get    :: Environment -> Var -> P(Lab)`

Retrieves all the bindings for the given variable from the environment.
