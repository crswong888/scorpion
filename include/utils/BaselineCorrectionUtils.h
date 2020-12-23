#pragma once

// LIBMESH includes
#include "DenseMatrix.h"
#include "libmesh/dense_vector.h"

/**
 * This namespace contains the functions used for the calculations corresponding
 * to the time history adjustment procedure in BaselineCorrection
 **/
namespace BaselineCorrectionUtils
{
/// Evaluates an integral over a single time step with Newmark-beta method. This reduces to a simple
/// trapezoidal integration rule when gamma = 0.5 and is used as such for displacement fits.
Real newmarkGammaIntegrate(const Real & u_ddot_old,
                           const Real & u_ddot,
                           const Real & u_dot_old,
                           const Real & gamma,
                           const Real & dt);

/// Evaluates a double integral over a single time step with Newmark-beta method
Real newmarkBetaIntegrate(const Real & u_ddot_old,
                          const Real & u_ddot,
                          const Real & u_dot_old,
                          const Real & u_old,
                          const Real & beta,
                          const Real & dt);

/// Solves linear normal equation for minimum acceleration square error
DenseVector<Real> getAccelerationFitCoeffs(unsigned int order,
                                           const std::vector<Real> & accel,
                                           const std::vector<Real> & t,
                                           const unsigned int & num_steps,
                                           const Real & gamma);

/// Solves linear normal equation for minimum velocity square error
DenseVector<Real> getVelocityFitCoeffs(unsigned int order,
                                       const std::vector<Real> & accel,
                                       const std::vector<Real> & vel,
                                       const std::vector<Real> & t,
                                       const unsigned int & num_steps,
                                       const Real & beta);

/// Solves linear normal equation for minimum displacement square error
DenseVector<Real> getDisplacementFitCoeffs(unsigned int order,
                                           const std::vector<Real> & disp,
                                           const std::vector<Real> & t,
                                           const unsigned int & num_steps);

/// Evaluates the least squares polynomials over at a single time step
std::vector<Real>
computePolynomials(unsigned int order, const DenseVector<Real> & coeffs, const Real & t);

} // namespace BaselineCorrectionUtils
