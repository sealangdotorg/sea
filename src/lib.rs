//
//   Copyright (C) 2014-2024 The SEA Language <https://sealang.org>
//   All rights reserved.
//
//   Developed by: Philipp Paulweber et al.
//   <https://github.com/sealangdotorg/sea/graphs/contributors>
//
//   This file is part of sea.
//
//   sea is free software: you can redistribute it and/or modify it
//   under the terms of the Mozilla Public License Version 2.0 (MPL-2.0).
//
//   sea is distributed in the hope that it will be useful, but WITHOUT
//   ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
//   or FITNESS FOR A PARTICULAR PURPOSE.
//   See the MPL-2.0 License for more details.
//
//   You should have received a copy of the MPL-2.0 License along with sea.
//   If not, see <https://www.mozilla.org/en-US/MPL/2.0/>.
//
//   Please note that the attached MPL-2.0 license provides two additional
//   exceptions in order to use the generated source code produced by sea
//   compiler as well as the linking and integrating of sea interpreter
//   runtime with the users license choice as long as the sea source code
//   is unchanged and unaffected in any way.
//

//! # The SEA Language

//! This crate contains the [Specifying Evolving Algebra (SEA)](https://sealang.org) language implementation.

use shadow_rs::shadow;

shadow!(build);
