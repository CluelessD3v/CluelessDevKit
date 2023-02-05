local Types = {}
export type Array<T> = {number: T}
export type Map<K, T> = {K: T}
export type Matrix<T> = {number:{number: T}}


return Types