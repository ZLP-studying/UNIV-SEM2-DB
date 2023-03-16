import random
print("insert into structures(object_id, room_type_id, square) \n values")
for i in range(1,51):
    j = random.randint(1,8)
    for k in range(j):
        print("(" + str(i)+ ",",str(random.randint(1,4))+",",str(random.randint(5,50))+"),")
