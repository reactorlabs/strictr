# Abstract Domains

The abstract domains for strictness analysis are specified below along with the basic data types and interfaces for some fundamental functions.

## Overview

### Syntactic Categories

```
v ∈ Var
l ∈ Lab
c ∈ Code
g ∈ Gid
e ∈ Eid
```

### Data Types

#### Type

```
Type ::= Promise
       | Function
```

#### State

```
State ::= Always
        | Never
        | Sometimes 
```

#### Graph (Interface)

```
clone     :: Graph -> Graph
force     :: Graph -> Natural -> Graph
merge     :: Graph -> Graph -> Graph
state     :: Graph -> Natural -> State
first     :: Graph -> P(Natural)
next      :: Graph -> Natural -> P(Natural)
always    :: Graph -> P(Natural)
never     :: Graph -> P(Natural)
sometimes :: Graph -> P(Natural)
```

#### Environment (Interface)

```
clone  :: Environment -> Environment
merge  :: Environment -> Environment -> Environment
add    :: Environment -> Var -> Lab -> Environment
remove :: Environment -> Var -> Environment
get    :: Environment -> Var -> P(Lab)
```

### Maps

```
M_e ::= [Eid ↦ Environment]
M_g ::= [Gid ↦ Graph]
M_c ::= [Lab ↦ Code]
M_t ::= [Lab ↦ Type]
M_a ::= [Lab ↦ (Eid, Gid)]
M_p ::= [Lab ↦ Natural]
M_s ::= [Lab ↦ Bool]
```

## Definitions

### Var

`Var` is the set of variables used in the program. Variables point to functions or promises or values we don't care about.

### Lab

`Lab` is the set of labels. There is a unique label for each function and promise. 

### Code

`Code` is the set of expressions or body of any function or promise.

### Gid

`Gid` is the set of identifiers for uniquely identifying the `Graph`.

### Eid

`Eid` is the set of identifiers for uniquely identifying the `Environment`.

### Type

`Type` specifies the type of labeled entity, either a `Function` or a `Promise`.

### State

`State` specifies the strictness state of a particular argument position, one of `Always`, `Never` and `Sometimes`.

### Environment Map 

`M_e ::= [Eid ↦ Environment]`

Maps each `Eid` to a unique `Environment`. `Eid` adds a layer of indirection needed to pair up the same `Graph` with different `Environment`.

### Graph Map

`M_g ::= [Gid ↦ Graph]`

Maps each `Gid` to a unique `Environment`. `Gid` adds a layer of indirection needed to pair up the same `Environment` with different `Graph`.

### Code Map

`M_c ::= [Lab ↦ Code]`

Maps each `Lab` to its unique `Code`.

### Type Map

`M_t ::= [Lab ↦ Type]`

Maps each `Lab` to the type of syntactic entity it labels, a `Function` or a `Promise`.

### Abstract State Map

`M_a ::= [Lab ↦ (Eid, Gid)]`

Maps each `Lab` to its abstract state, i.e., a tuple of `Eid` and `Gid`.

### Position Map

`M_p ::= [Lab ↦ Natural]`

Maps each `Lab` which labels a `Promise` to its argument position in the corresponding `Function`.

### Forced Map

`M_s ::= [Lab ↦ Bool]`

Maps each `Lab` which labels a `Promise` to its forced state, `True` or `False`.

### Graph (Interface)

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

#### state
`state     :: Graph -> Natural -> State`
Returns the state of the argument at the given position.

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
