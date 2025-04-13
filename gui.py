import tkinter as tk
from mysql import connector
from dotenv import load_dotenv
import os

load_dotenv()

class ScrollableFrame(tk.Frame):
    def __init__(self, container, *args, **kwargs):
        super().__init__(container, *args, **kwargs)
        
        # Create canvas and scrollbar
        self.canvas = tk.Canvas(self)
        self.scrollbar = tk.Scrollbar(self, orient="vertical", command=self.canvas.yview)
        
        # Create a frame inside the canvas
        self.scrollable_frame = tk.Frame(self.canvas)
        
        # Configure the canvas to scroll the frame
        self.scrollable_frame.bind(
            "<Configure>",
            lambda e: self.canvas.configure(scrollregion=self.canvas.bbox("all"))
        )
        
        # Add the frame to the canvas
        self.canvas.create_window((0, 0), window=self.scrollable_frame, anchor="nw")
        
        # Configure canvas scrolling
        self.canvas.configure(yscrollcommand=self.scrollbar.set)
        
        # Pack widgets
        self.scrollbar.pack(side="right", fill="y")
        self.canvas.pack(side="left", fill="both", expand=True)

class TrainWidget():
    def __init__(self,owner,places,x,y):
        self.places = places
        self.x = x
        self.y = y
        for i in range(len(self.places) - 1): self.places[i] = self.places[i] + ".  --->"
        self.labels = [tk.Label(owner,text = x,) for x in self.places]
        for i in range(len(self.labels)): self.labels[i].place(x = self.x + 70*i + 45,y = self.y )
        
        self.seatEntry = tk.Entry(owner,width=5)
        self.seatEntry.place(x = self.x,y = self.y + 10)

        self.button_vars = [tk.BooleanVar() for _ in self.places]
        self.buttons = [tk.Checkbutton(owner,text = "",variable=self.button_vars[i]) for i in range(len(places))]
        for i in range(len(self.buttons)): self.buttons[i].place(x = self.x+ 70*i + 5 + 45,y = self.y + 15)

    def getCheckboxes(self):
        seat = self.seatEntry.get()
        checked_places = []
        for i, var in enumerate(self.button_vars):
            if var.get():
                checked_places.append(i)
        return [int(seat),checked_places]



window = tk.Tk()
window.geometry("600x600")

db = connector.connect(
    user=os.getenv("MYSQL_USER"),
    password=os.getenv("MYSQL_PASSWORD"),
    host=os.getenv("MYSQL_HOST"),
    database=os.getenv("MYSQL_DATABASE"),
)
cursor = db.cursor()

opening = tk.Frame(window)
opening.pack(fill="both", expand=True)

AddCustomer = tk.Frame(window)
AddCustomer.forget()

TrainView = ScrollableFrame(window)
TrainView.forget()

def gotoTrainView():
    opening.forget()
    TrainView.tkraise()
    TrainView.pack(fill="both", expand=True)

def gotoAddCustomer():
    opening.forget()
    AddCustomer.tkraise()
    AddCustomer.pack(fill="both", expand=True)

add_customer = tk.Button(opening,text = "Add Customer",width = 20,command = gotoAddCustomer)
see_trains = tk.Button(opening,text = "See Trains",width = 20,command= gotoTrainView)
add_customer.place(x = 230, y = 50)
see_trains.place(x = 230, y = 100)

# add customer
customer_name = tk.Entry(AddCustomer)
customer_age = tk.Entry(AddCustomer)
customer_name.place(x = 230,y = 100)
customer_age.place(x = 230,y = 200)

def submitSubway():
    cname = customer_name.get()
    cage = int(customer_age.get())
    print(cage)
    if( cage < 60 ): cclass = "General"
    else: cclass = "senior"
    cursor.execute("CALL AddCustomer(%s,%s,%s)",(cname,cclass,cage))
    db.commit()

Subway = tk.Button(AddCustomer,text = "Just Monika",width = 20,command = submitSubway)
Subway.place(x = 230, y = 300)


#train view

tvl1 = tk.Label(TrainView,text = "Customer ID")
cust_id = tk.Entry(TrainView)
tvl1.place(x = 300,y = 300)
cust_id.place(x = 300,y = 350)

cursor.execute("SELECT tid,origin,dest,departure from Routes order by tid,departure")
places = []
curr = None
prev = None
for (tid,origin,dest,departure) in cursor:
    print(tid)
    if(tid != curr):
        curr = tid
        places.append([])
    if(len(places[len(places) - 1])): places[len(places) - 1].pop()
    places[len(places) - 1].extend((origin,dest))
    prev = dest

train_widgets = [TrainWidget(TrainView,places[i],30,20 + 30 * i) for i in range(len(places))]

def submitPath():
    ret = []
    for i in range(len(train_widgets)):
        ret.append(train_widgets[i].getCheckboxes())
    print(ret)
    return ret

submit_path = tk.Button(TrainView,text= "Submit",command= submitPath)
submit_path.place(x = 200,y = 200)

opening.tkraise()
    
window.mainloop()