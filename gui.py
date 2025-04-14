import tkinter as tk
from tkinter import ttk
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
customer_name.place(x = 270,y = 100)
customer_age.place(x = 270,y = 200)

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
tvl1 = tk.Label(TrainView, text="Customer ID")
tvl1.place(x=270, y=350-20)
cust_id = tk.Entry(TrainView)
cust_id.place(x=240, y=350)

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
    seats = [x for x in range(1,first_class + second_class + 1)]
    available = [1 for x in range(1,first_class + second_class + 1)]

    for i in range(len(seats)):
        for route in routes:
            cursor.execute("SELECT AvailableSeatQuery(%s, %s)", (route, seats[i]))
            result = cursor.fetchone()
            if result:
                available[i] = available[i] and result[0]


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
    customer_id = cust_id.get()
    # rids = {trainid:{"routes":[],seatnumber:INT}}
    rids = {}
    for x in train_widgets:
        if(len(x.getCheckboxes())):
            start,stop = x.getCheckboxes()
            cursor.execute("SELECT first_class,second_class FROM trains where tid = %s",(x.tid,))
            first,second = cursor.fetchone()
            seatnum = int(x.seatEntry.get())

            available = 1
            for route in train_data[x.tid]["routes"][start:stop]:
                cursor.execute("SELECT AvailableSeatQuery(%s, %s)", (route, seatnum))
                result = cursor.fetchone()

                print(result)
                available = available and result[0]

            rids[x.tid] = {"routes":train_data[x.tid]["routes"][start:stop],
                           "seatnumber":seatnum,
                           "seatclass":"first_class" if first >= seatnum else "second_class",
                           "btype":'normal' if available else 'rac'}

            print(rids)

    BillWindow = tk.Toplevel()
    BillWindow.geometry("600x600")
    BILLTEXT = tk.Label(BillWindow,text="BILL")
    BILLTEXT.place(y = 10,x = 270)
    Mytree = ttk.Treeview(BillWindow)
    Mytree['columns'] = ("rid","origin","destination","base price","final price")

    Mytree.column("#0", width=0)
    Mytree.column("rid",width=100)
    Mytree.column("origin",width=100)
    Mytree.column("destination",width=100)
    Mytree.column("base price",width=100)
    Mytree.column("final price",width=100)

    Mytree.heading("#0", text="")
    Mytree.heading("rid", text="Route ID")
    Mytree.heading("origin", text="Origin")
    Mytree.heading("destination", text="Destination")
    Mytree.heading("base price", text="Base Price")
    Mytree.heading("final price", text="Final Price")

    Mytree.pack(expand=False)
    Mytree.place(y = 30,x = 40)

    bill = []
    for tid,data in rids.items():
        for route in data["routes"]:
            cursor.execute("CALL GenItemizedBill(%s,%s,%s)",(customer_id,route,data["seatclass"]))
            origin,destination,seat_class,concession_class,base_price,seat_class_discount,concession_class_discount,final_price = cursor.fetchone()
            while cursor.nextset():
                pass
            bill.append([route,origin,destination,base_price,final_price])

    IID = 0
    for x in bill:
        Mytree.insert(parent='',index='end',iid=IID,values= x)
        IID+=1

    # Add a total row if needed
    if bill:
        total_price = sum(item[4] for item in bill)  # Sum of final prices
        Mytree.insert(parent='', index='end', iid=len(bill),
                     values=("TOTAL", "", "", "", f"{total_price:.2f}"),
                     tags=('total',))
        Mytree.tag_configure('total', background='light gray', font=('Arial', 10, 'bold'))



    tvl3 = tk.Label(BillWindow, text="Payment ID")
    tvl3.place(x=80, y=400-20)
    p_id = tk.Entry(BillWindow)
    p_id.place(x=80, y=400)

    tvl4 = tk.Label(BillWindow, text="Payment Type")
    tvl4.place(x=250, y=400-20)
    p_type = tk.Entry(BillWindow)
    p_type.place(x=250, y=400)

    tvl5 = tk.Label(BillWindow, text="Payment Amount")
    tvl5.place(x=430, y=400-20)
    p_amount = tk.Entry(BillWindow)
    p_amount.place(x=430, y=400)

    def do_a_booking():
        Payment_ID = p_id.get()
        Payment_Type = p_type.get()
        Payment_amount = p_amount.get()

        for x,y in rids.items():
            cursor.execute("CALL CreateBooking(%s,%s,%s,%s,%s,%s,%s)", (customer_id,
                                                                        Payment_ID,
                                                                        Payment_Type,
                                                                        Payment_amount,
                                                                        y["btype"],
                                                                        y["seatclass"],
                                                                        y["seatnumber"]
                                                                        ))
            pnr = cursor.fetchone()[0]
            while cursor.nextset():
                pass

            db.commit()
            for rid in y["routes"]:
                cursor.execute("CALL InsertBookingRoute(%s,%s)",(pnr,rid))
            db.commit()
        BillWindow.destroy()



    DoABooking = tk.Button(BillWindow,text="Book",command=do_a_booking)
    DoABooking.place(x = 270,y = 500)

    BillWindow.mainloop()



submit_path = tk.Button(TrainView,text= "Submit",command= submitPath)
submit_path.place(x = 270,y = 400)
opening.tkraise()
window.mainloop()