import tkinter as tk
from tkinter import font as tkfont
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
    cursor.execute("CALL InsertCustomer(%s,%s,%s)",(cname,cclass,cage))
    db.commit()

Subway = tk.Button(AddCustomer,text = "Insert Customer",width = 20,command = submitSubway)
Subway.place(x = 230, y = 300)


#train view
tvl1 = tk.Label(TrainView,text = "Customer ID")
cust_id = tk.Entry(TrainView)
tvl1.place(x = 300,y = 300)
cust_id.place(x = 300,y = 350)

cursor.execute("SELECT rid,tid,origin,dest,departure from Routes order by tid,departure")

# train_data = {"tid": {"places":[],"routes":[]}}
train_data = {}
for (rid,tid,origin,dest,departure) in cursor:
    if(tid not in train_data.keys()):
        train_data[tid] = {"places":[],"routes":[]}
    if(len(train_data[tid]["places"])):train_data[tid]["places"].pop()
    train_data[tid]["places"].extend((origin,dest))
    train_data[tid]["routes"].append(rid)

def createSeatMatrix(tid,start,end):
    cursor.execute("SELECT first_class,second_class from Trains where tid = %s",(tid,))
    first_class,second_class = cursor.fetchone()
    routes = train_data[tid]["routes"][start:end]
    for i in range(1,first_class + second_class + 1):
        cursor.executemany("SELECT AvailableSeatQuery(%s,%s)",[(x,i) for x in routes])
        for x in cursor: available[i] = available[i] and x
    
    seats = [x for x in range(1,first_class + second_class + 1)]
    available = [1 for x in range(1,first_class + second_class + 1)]
    seatMatrix = tk.Toplevel()
    seatMatrix.geometry("600x600")
     
    frame = tk.Frame(seatMatrix)
    frame.pack(expand=True, fill=tk.BOTH, padx=20, pady=20)

    # Calculate rows and columns for the grid
    total_seats = first_class + second_class
    columns = 8  # You can adjust this value
    rows = (total_seats + columns - 1) // columns

    custom_font = tkfont.Font(family="Helvetica", size=10, weight="bold")

    # Create a visual separator between first and second class
    first_class_label = tk.Label(frame, text="First Class", font=custom_font)
    first_class_label.grid(row=0, column=0, columnspan=columns, pady=(0, 10))

    for i, seat in enumerate(seats):
        row = (i // columns) + 1  # +1 to account for the header row
        col = i % columns
        
        text_color = "#FFFFFF" if available[i] == 1 else "#E0E0E0"
        
        # Create a label for each seat
        seat_label = tk.Label(frame, text=str(seat), font=custom_font, bg=text_color,
                         width=4, height=2, relief=tk.RIDGE, borderwidth=1)
        seat_label.grid(row=row, column=col, padx=0, pady=0)
        
        # Add a separator row between first and second class
        if seat == first_class:
            separator_row = row + 1
            separator = tk.Label(frame, text="Second Class", font=custom_font)
            separator.grid(row=separator_row, column=0, columnspan=columns, pady=(10, 10))
            
            # Adjust row position for remaining seats
            for j in range(i+1, len(seats)):
                adjusted_row = (((j - i - 1) // columns) + 4)  # +2 to account for header and separator
                adjusted_col = (j - i - 1) % columns
                
                # Determine text color for the remaining seats
                adjusted_text_color = "#FFFFFF" if available[j] == 1 else "#E0E0E0"
                
                # Create a label for each remaining seat
                adjusted_seat_label = tk.Label(frame, text=str(seats[j]), font=custom_font, 
                                        bg=adjusted_text_color, width=4, height=2, 
                                        relief=tk.RIDGE, borderwidth=1)
                adjusted_seat_label.grid(row=adjusted_row, column=adjusted_col, padx=0, pady=0)
            
            # Break the loop as we've handled all seats
            break

    # Configure grid to be responsive
    for i in range(columns):
        frame.columnconfigure(i, weight=1)
    for i in range(rows+2):  # +2 for headers
        frame.rowconfigure(i, weight=1)

    seatMatrix.mainloop()

def createSeatMatrixWrapper(train_widget):
    createSeatMatrix(train_widget.tid,*train_widget.getCheckboxes())

class TrainWidget():
    def __init__(self,owner,places,x,y,tid):
        self.places = places
        self.x = x
        self.y = y
        self.tid = tid
        for i in range(len(self.places) - 1): self.places[i] = self.places[i] + ".  --->"
        self.labels = [tk.Label(owner,text = x,) for x in self.places]
        for i in range(len(self.labels)): self.labels[i].place(x = self.x + 70*i + 150,y = self.y )
        
        self.seatEntry = tk.Entry(owner,width=5)
        self.seatEntry.place(x = self.x,y = self.y + 10)
        self.seatMatrix = tk.Button(owner,text="Seat Matrix",command=lambda: createSeatMatrixWrapper(self))
        self.seatMatrix.place(x = self.x + 50,y = self.y + 10)

        self.button_vars = [tk.BooleanVar() for _ in self.places]
        self.buttons = [tk.Checkbutton(owner,text = "",variable=self.button_vars[i]) for i in range(len(places))]
        for i in range(len(self.buttons)): self.buttons[i].place(x = self.x+ 70*i + 5 + 150,y = self.y + 15)

    def getCheckboxes(self):
        checked_places = []
        for i, var in enumerate(self.button_vars):
            if var.get():
                checked_places.append(i)
        return checked_places

train_widgets = [TrainWidget(TrainView,train_data[i]["places"],30,20 + 30 * num,i) for num,i in enumerate(train_data.keys())]

def submitPath():
    ret = []
    for i in range(len(train_widgets)):
        ret.append(train_widgets[i].getCheckboxes())
    print(ret)
    return ret

submit_path = tk.Button(TrainView,text= "Submit",command= submitPath)
submit_path.place(x = 200,y = 200)
opening.tkraise()
createSeatMatrix(1,0,1)
window.mainloop()