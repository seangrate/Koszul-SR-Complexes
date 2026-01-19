doc ///
  Key
    hessian
    (hessian, RingElement)
    (hessian, RingElement, ZZ)
    (hessian, RingElement, List)
  Headline
    computes the Hessian of a polynomial
  Usage
    hessian G
    hessian(G, d)
    hessian(G, Bd)
  Inputs
    G:RingElement
    d:ZZ
    Bd:List
  Outputs
    :RingElement
  Description
    Text
      Following the definition from Maeno-Numata [2016], suppose $\mathbb{K}$
      is a field of characteristic $0$, and let $G$ be a polynomial in
      $\mathbb{K}[x_1,\dots,x_n]$. Let $\mathbf{B}_d = \{ \alpha_i^{(d)}}_i$
      be a family of homogeneous polynomials of degree $d > 0$, where
      $\alpha_i^{(d)} \in \mathbb{KK}[X_1,\dots,X_n]$ (identifying $X_i$ with
      $\frac{\partial}{\partial x_i}). We say that the polynomial
      $$ \det{\left( ( \alpha_i^{(d)}(X) \alpha_j^{(d)}(X) G(x) )_{i,j=1}^{\lvert \mathbf{B}_d \rvert} \right)} \in \mathbb{K}[x_1,\dots,x_n]$$
      is the \emph{$d$th Hessian} of $G$ with respect to $\mathbf{B}_d$, and 
      denote it by $\text{Hess}_{\mathbf{B}_d}^{(d)} G$. We denote the $d$th 
      Hessian by $\text{Hess}^{(d)} G$ if the choice of $\mathbf{B}_d$ is 
      clear.

      When $d=1$ and $\alpha_j^{(1)}(X) = X_j$ for $j = 1,\dots,n$, the first 
      Hessian $\text{Hess}^{(1)} G$ coincides with the usual Hessian:
      $$\text{Hess}^{(1)} G = \text{Hess} G = \det{\left( \frac{\partial^2 G}{\partial x_i \partial x_j} \right)_{i,j}}.$$
    Example
      R = QQ[x_1..x_3]
      f = x_1^2 + x_2*x_3
      hessian f
    Text
      When positive integer is passed as the second argument, this computes the 
      $d$th Hessian of the input polynomial $f$ with respect to the standard
      monomial basis of $\mathbb{K}[x_1,\dots,x_n]_d$.
    Example
      hessian(f, 2)
    Text
      When a list of homogeneous polynomials of degree $d > 0$ is passed as the
      second argument, this computes the Hessian with respect to that family; 
      i.e., the second argument is the family $\mathbf{B}_d$ in the above
      definition.
    Example
      hessian(f, flatten entries basis(1, R))
  Caveat
    This method assumes that the characteristic of the base field is $0$.
///