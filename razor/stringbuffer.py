import io

class StringBuffer:

  def __init__(self):
    self.empty = True
    self._stringio = io.StringIO()

  def __str__(self):
    val = self._stringio.getvalue()
    self._stringio.close()
    return val

  def append(self, obj):
    data = str(obj)
    if self.empty and len(data) > 0:
      self.empty = False
    self._stringio.write(data)
    return self

  def isempty(self):
    return self.empty
