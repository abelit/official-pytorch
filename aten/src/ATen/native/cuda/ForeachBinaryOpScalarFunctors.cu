#include <ATen/Dispatch.h>
#include <ATen/native/ForeachUtils.h>
#include <ATen/native/cuda/ForeachFunctors.cuh>

namespace at { namespace native {

template<template<class> class Op>
std::vector<Tensor> foreach_binary_op(TensorList tensors, Scalar scalar) {
    verify_list(tensors);

    std::vector<std::vector<at::Tensor>> tensor_lists; 
    std::vector<at::Tensor> vec_res;
    for (const auto& t: tensors) {
        vec_res.emplace_back(at::native::empty_like(t));
    }

    tensor_lists.emplace_back(std::move(tensors.vec()));
    tensor_lists.emplace_back(std::move(vec_res));

    AT_DISPATCH_ALL_TYPES_AND_COMPLEX_AND3(kBool, kBFloat16, kHalf, tensors[0].scalar_type(), "foreach_tensor_add_scalar_kernel_cuda", [&]() {
        multi_tensor_apply<2>(tensor_lists, BinaryOpScalarFunctor<scalar_t, Op>(), scalar.to<scalar_t>());
    });
    return tensor_lists[1];
}

template<template<class> class Op>
std::vector<Tensor> foreach_binary_op_(TensorList tensors, Scalar scalar) {
    verify_list(tensors);

    std::vector<std::vector<at::Tensor>> tensor_lists; 
    tensor_lists.emplace_back(std::move(tensors.vec()));

    AT_DISPATCH_ALL_TYPES_AND_COMPLEX_AND3(kBool, kBFloat16, kHalf, tensors[0].scalar_type(), "foreach_tensor_add_scalar_kernel_cuda_", [&]() {
        multi_tensor_apply<1>(tensor_lists, BinaryOpScalarFunctor_<scalar_t, Op>(), scalar.to<scalar_t>());
    });
    return tensor_lists[0];
}

std::vector<Tensor> foreach_tensor_add_scalar_kernel_cuda(TensorList tensors, Scalar scalar) {
    TORCH_CHECK(tensors.size() > 0, "Tensor list must have at least one tensor.");

    if (!check_fast_route(tensors, scalar)) {
        return at::native::foreach_add_scalar_kernel_fallback(tensors, scalar);
    }

    return foreach_binary_op<std::plus>(tensors, scalar);
}

std::vector<Tensor> foreach_tensor_add_scalar_kernel_cuda_(TensorList tensors, Scalar scalar) {
    verify_list(tensors);

    if (!check_fast_route(tensors, scalar)) {
        return at::native::foreach_add_scalar_kernel_fallback_(tensors, scalar);
    }

    return foreach_binary_op_<std::plus>(tensors, scalar);
}

std::vector<Tensor> foreach_tensor_sub_scalar_kernel_cuda(TensorList tensors, Scalar scalar) {
    TORCH_CHECK(tensors.size() > 0, "Tensor list must have at least one tensor.");

    if (!check_fast_route(tensors, scalar)) {
        return at::native::foreach_sub_scalar_kernel_fallback(tensors, scalar);
    }

    return foreach_binary_op<std::minus>(tensors, scalar);
}

std::vector<Tensor> foreach_tensor_sub_scalar_kernel_cuda_(TensorList tensors, Scalar scalar) {
    TORCH_CHECK(tensors.size() > 0, "Tensor list must have at least one tensor.");

    if (!check_fast_route(tensors, scalar)) {
        return at::native::foreach_sub_scalar_kernel_fallback_(tensors, scalar);
    }

    return foreach_binary_op_<std::minus>(tensors, scalar);
}

std::vector<Tensor> foreach_tensor_mul_scalar_kernel_cuda(TensorList tensors, Scalar scalar) {
    TORCH_CHECK(tensors.size() > 0, "Tensor list must have at least one tensor.");

    if (!check_fast_route(tensors, scalar)) {
        return at::native::foreach_mul_scalar_kernel_fallback(tensors, scalar);
    }

    return foreach_binary_op<std::multiplies>(tensors, scalar);
}

std::vector<Tensor> foreach_tensor_mul_scalar_kernel_cuda_(TensorList tensors, Scalar scalar) {
    TORCH_CHECK(tensors.size() > 0, "Tensor list must have at least one tensor.");

    if (!check_fast_route(tensors, scalar)) {
        return at::native::foreach_mul_scalar_kernel_fallback_(tensors, scalar);
    }

    return foreach_binary_op_<std::multiplies>(tensors, scalar);
}

std::vector<Tensor> foreach_tensor_div_scalar_kernel_cuda(TensorList tensors, Scalar scalar) {
    TORCH_CHECK(tensors.size() > 0, "Tensor list must have at least one tensor.");

    if (!check_fast_route(tensors, scalar)) {
        return at::native::foreach_div_scalar_kernel_fallback(tensors, scalar);
    }

    return foreach_binary_op<std::divides>(tensors, scalar);
}

std::vector<Tensor> foreach_tensor_div_scalar_kernel_cuda_(TensorList tensors, Scalar scalar) {
    TORCH_CHECK(tensors.size() > 0, "Tensor list must have at least one tensor.");

    if (!check_fast_route(tensors, scalar)) {
        return at::native::foreach_div_scalar_kernel_fallback_(tensors, scalar);
    }

    return foreach_binary_op_<std::divides>(tensors, scalar);
}

}} // namespace at::native
