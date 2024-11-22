public class ITRWrapper extends ParentAPIResponse {
		public List<Itr> itr;
        public List<Itrv> itrv;
        public Form26ASDetails form26ASDetails;

        public class Itr {
            public String type;
            public String fy;
            public String grossTotalIncome;
			public String totalIncome;
        }

        public class Form26ASDetails {
            public String financialYear;
            public List<Gstr3bTurnoverDetailsList> gstr3bTurnoverDetailsList;
        }

        public class Gstr3bTurnoverDetailsList {
            public String taxableTurnover;
        }

        public class Itrv {
            public String financialYear;
            public String formNumber;
            public String grossTotalIncome;
			public String totalIncome;
        }
}