Complex case where user only needs one function, which itself may call other functions
dependent on the mode passed to it. Additionally this is done via function pointers.

It should keep not only the decide function, but any function which could be assigned to
operator inside the switch statement

