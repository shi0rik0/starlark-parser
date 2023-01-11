def f(*args, **kwargs):
  return args, kwargs

def while_break(n):
  r = 0
  for i in range(1000):
    if n == 5:
      break
    r += n
    n -= 1
  return r

def while_continue(n):
  r = 0
  for i in range(1000):
    if n <= 0:
      break
    if n % 2 == 0:
      n -= 1
      continue
    r += n
    n -= 1
  return r

def fib(n):
  seq = []
  x = 0
  y = 1
  for i in range(n):
    if len(seq) == n:
      break
    seq.append(x)
    x, y = y, x + y
  return seq