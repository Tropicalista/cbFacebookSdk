component extends="" {

    property name="graphObjectMap" default= "{
            'hometown' = 'GraphPage',
            'location' = 'GraphPage',
            'significant_other' = 'GraphUser',
            'picture' = 'GraphPicture',
        }";


    public function getId(){
        return getField('id');
    }

    public function getName(){
        return getField('name');
    }

    public function getFirstName(){
        return getField('first_name');
    }

    public function getMiddleName(){
        return getField('middle_name');
    }

    public function getLastName(){
        return getField('last_name');
    }

    public function getEmail(){
        return getField('email');
    }

    public function getGender(){
        return getField('gender');
    }

    public function getLink(){
        return getField('link');
    }

    public function getBirthday(){
        return getField('birthday');
    }

    public function getLocation(){
        return getField('location');
    }

    public function getHometown(){
        return getField('hometown');
    }

    public function getSignificantOther(){
        return getField('significant_other');
    }

    public function getPicture(){
        return getField('picture');
    }
}
