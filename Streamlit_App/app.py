import pandas as pd
import streamlit as st
import matplotlib.pyplot as plt

@st.cache
def load_data():
    df = pd.read_csv("/Users/shobabhagwat/Documents/streamlit/data/ted.csv")
    return df

df = load_data()

def main():
    page = st.sidebar.selectbox(
        "Select a Page",
        [
            "Homepage"
        ]
    )

    if page == "Homepage":
       # st.header("Data Application")
        """
        # Building application with Streamlit
        Please select a page on the left
        """
        st.balloons()
        st.table(df)


if __name__ == "__main__":
    main()








